-- Sourcegraph-style query syntax for fzf-lua live_grep.
--
-- Supported keywords (anywhere in the query, space-separated):
--   f:PATTERN    include only paths matching PATTERN
--   -f:PATTERN   exclude paths matching PATTERN
--   l:NAME       restrict to language NAME (ts, py, lua, ...)
--   -l:NAME      exclude language NAME
--   d:DIR        search in DIR (overrides cwd; relative to cwd)
--   w:WORD       match WORD with regex word boundaries (\bWORD\b)
--   c:yes        case-sensitive (overrides --smart-case)
--
-- Remaining bare tokens form the regex pattern.

local M = {}

-- ---------------------------------------------------------------------------
-- rg --type-list cache. Populated at setup() and baked into fn_transform_cmd.
-- ---------------------------------------------------------------------------

-- Fallback list used when `rg --type-list` is unavailable at setup time.
local FALLBACK_LANG_EXTS = {
  ts  = { "ts", "tsx", "cts", "mts" },
  js  = { "js", "jsx", "cjs", "mjs" },
  lua = { "lua" },
  py  = { "py", "pyi" },
  go  = { "go" },
  rs  = { "rs" },
  md  = { "md", "markdown" },
  json = { "json" },
  yaml = { "yaml", "yml" },
}

local LANG_EXTS = FALLBACK_LANG_EXTS

-- Parses `rg --type-list` output (one line per type: "name: *.ext1, *.ext2, lit").
-- Only picks up star-extension globs; bare-filename globs are ignored (there
-- is no way to express them via our composite glob).
local function parse_type_list(text)
  local map = {}
  for line in text:gmatch("[^\r\n]+") do
    local name, rest = line:match("^([%w_%-]+):%s*(.*)$")
    if name then
      local exts = {}
      for g in rest:gmatch("[^,]+") do
        local ext = g:match("^%s*%*%.([%w]+)%s*$")
        if ext then exts[#exts + 1] = ext end
      end
      if #exts > 0 then map[name:lower()] = exts end
    end
  end
  return map
end

-- ---------------------------------------------------------------------------
-- Shared helpers (used by header_for / CLI path only — NOT by fn_transform_cmd)
-- ---------------------------------------------------------------------------

local function shellescape(s)
  return "'" .. (s:gsub("'", [['\'']])) .. "'"
end

local function tokenize(query)
  local tokens = {}
  local i, n = 1, #query
  while i <= n do
    local c = query:sub(i, i)
    if c:match("%s") then
      i = i + 1
    else
      local start, negate = i, (c == "-")
      local buf, in_quote = {}, false
      while i <= n do
        local ch = query:sub(i, i)
        if ch == '"' then
          in_quote = not in_quote
          i = i + 1
        elseif ch:match("%s") and not in_quote then
          break
        else
          buf[#buf + 1] = ch
          i = i + 1
        end
      end
      tokens[#tokens + 1] = {
        raw = query:sub(start, i - 1),
        text = table.concat(buf),
        negate = negate,
      }
    end
  end
  return tokens
end

local KEYWORDS = {
  f = "path",
  l = "lang",
  d = "dir",
  w = "word",
  c = "case",
}

local function classify(tok)
  local body = tok.negate and tok.text:sub(2) or tok.text
  local key, val = body:match("^([%w_]+):(.*)$")
  if not key then return nil end
  local kind = KEYWORDS[key:lower()]
  if not kind then return nil end
  if val:sub(1, 1) == '"' and val:sub(-1) == '"' then
    val = val:sub(2, -2)
  end
  return kind, val
end

-- ---------------------------------------------------------------------------
-- fn_transform_cmd: built from a template at setup(). The LANG_EXTS table is
-- inlined into the template so the function has no upvalues — fzf-lua
-- string.dump()s it and reloads it in a headless nvim child where module
-- upvalues are unreachable.
-- ---------------------------------------------------------------------------

local FN_TEMPLATE = [===[
return function(query, cmd, _opts)
  local LANG_EXTS = %s
  local STDERR_FILE = %s

  local function shellescape(s) return "'" .. (s:gsub("'", [['\'']])) .. "'" end
  local function tokenize(q)
    local tokens, i, n = {}, 1, #q
    while i <= n do
      local c = q:sub(i, i)
      if c:match("%%s") then i = i + 1
      else
        local start, negate, buf, in_quote = i, (c == "-"), {}, false
        while i <= n do
          local ch = q:sub(i, i)
          if ch == '"' then in_quote = not in_quote; i = i + 1
          elseif ch:match("%%s") and not in_quote then break
          else buf[#buf + 1] = ch; i = i + 1 end
        end
        tokens[#tokens + 1] = { raw = q:sub(start, i - 1), text = table.concat(buf), negate = negate }
      end
    end
    return tokens
  end
  local KEYWORDS = { f = "path", l = "lang", d = "dir", w = "word", c = "case" }
  local function classify(tok)
    local body = tok.negate and tok.text:sub(2) or tok.text
    local key, val = body:match("^([%%w_]+):(.*)$")
    if not key then return nil end
    local kind = KEYWORDS[key:lower()]
    if not kind then return nil end
    if val:sub(1, 1) == '"' and val:sub(-1) == '"' then val = val:sub(2, -2) end
    return kind, val
  end

  local path_incl, path_excl = {}, {}
  local lang_incl, lang_excl = {}, {}
  local words, dirs = {}, {}
  local pattern_parts = {}
  local case_sensitive = false

  -- Wrap a user-supplied path fragment as a gitignore-style glob.
  -- - already contains *? : leave alone
  -- - contains /          : "**/<v>/**" so directory prefix matches anywhere
  -- - bare filename       : "*<v>*" so it matches anywhere in a basename
  local function path_glob(v)
    if v:find("[*?]") then return v end
    if v:find("/") then
      v = v:gsub("/+$", "")
      return "**/" .. v .. "/**"
    end
    return "*" .. v .. "*"
  end
  -- Companion: convert a path glob into one that ALSO restricts to specific
  -- file extensions (used when both f: and l: are present).
  local function path_glob_with_exts(v, ext_group)
    if v:find("[*?]") then
      -- User supplied their own pattern; stick the ext group on the end.
      local stripped = v:gsub("%%*+$", "")
      return stripped .. "." .. ext_group
    end
    if v:find("/") then
      v = v:gsub("/+$", "")
      return "**/" .. v .. "/**/*." .. ext_group
    end
    return "*" .. v .. "." .. ext_group
  end

  for _, tok in ipairs(tokenize(query)) do
    local kind, val = classify(tok)
    if kind == "path" and val ~= "" then
      if tok.negate then path_excl[#path_excl + 1] = val
      else path_incl[#path_incl + 1] = val end
    elseif kind == "lang" and val ~= "" then
      if tok.negate then lang_excl[#lang_excl + 1] = val:lower()
      else lang_incl[#lang_incl + 1] = val:lower() end
    elseif kind == "dir" and val ~= "" then
      dirs[#dirs + 1] = val
    elseif kind == "word" and val ~= "" then
      words[#words + 1] = val
    elseif kind == "case" then
      if val:lower() == "yes" or val == "true" or val == "1" then case_sensitive = true end
    elseif kind == nil then
      pattern_parts[#pattern_parts + 1] = tok.text
    end
  end

  -- Word boundaries: append as \bWORD\b to the pattern (rg defaults to PCRE2/Rust regex).
  for _, w in ipairs(words) do
    pattern_parts[#pattern_parts + 1] = "\\b" .. w .. "\\b"
  end

  local incl_exts, unknown_incl_langs = {}, {}
  for _, lang in ipairs(lang_incl) do
    local exts = LANG_EXTS[lang]
    if exts then
      for _, e in ipairs(exts) do incl_exts[#incl_exts + 1] = e end
    else
      unknown_incl_langs[#unknown_incl_langs + 1] = lang
    end
  end

  local args = {}
  if #path_incl > 0 and #incl_exts > 0 then
    local ext_group = "{" .. table.concat(incl_exts, ",") .. "}"
    for _, p in ipairs(path_incl) do
      args[#args + 1] = "--iglob=" .. shellescape(path_glob_with_exts(p, ext_group))
    end
  elseif #incl_exts > 0 then
    local ext_group = "{" .. table.concat(incl_exts, ",") .. "}"
    args[#args + 1] = "--iglob=" .. shellescape("*." .. ext_group)
  else
    for _, p in ipairs(path_incl) do
      args[#args + 1] = "--iglob=" .. shellescape(path_glob(p))
    end
  end
  for _, lang in ipairs(unknown_incl_langs) do
    args[#args + 1] = "--type=" .. shellescape(lang)
  end
  for _, p in ipairs(path_excl) do
    args[#args + 1] = "--iglob=" .. shellescape("!" .. path_glob(p))
  end
  for _, lang in ipairs(lang_excl) do
    local exts = LANG_EXTS[lang]
    if exts then
      for _, e in ipairs(exts) do
        args[#args + 1] = "--iglob=" .. shellescape("!*." .. e)
      end
    else
      args[#args + 1] = "--type-not=" .. shellescape(lang)
    end
  end
  if case_sensitive then args[#args + 1] = "--case-sensitive" end

  local pat = table.concat(pattern_parts, " ")
  if not cmd then return nil, pat end
  if pat == "" then return "true", "" end

  local extra = table.concat(args, " ")
  local trimmed = cmd:gsub("%%s+$", "")
  local new_cmd = trimmed
  if #extra > 0 then
    if trimmed:match(" %%-e$") then
      new_cmd = trimmed:gsub(" %%-e$", " " .. extra .. " -e")
    elseif trimmed:match(" %%-%%-$") then
      new_cmd = trimmed:gsub(" %%-%%-$", " " .. extra .. " --")
    else
      new_cmd = trimmed .. " " .. extra
    end
  end
  new_cmd = new_cmd .. " " .. shellescape(pat)
  -- d:DIR — rg accepts trailing paths as search roots.
  for _, d in ipairs(dirs) do
    new_cmd = new_cmd .. " " .. shellescape(d)
  end
  -- Capture stderr so the header can surface rg errors without polluting
  -- the result list. Use `tee` so errors still flow to fzf for visibility.
  -- Truncate stderr before each run so stale errors from a prior keystroke
  -- don't linger in the header.
  new_cmd = ": > " .. shellescape(STDERR_FILE) .. "; " .. new_cmd ..
      " 2> " .. shellescape(STDERR_FILE)
  return new_cmd, pat
end
]===]

-- Serialize a table of {name = {ext1, ext2, ...}} to a Lua literal.
local function serialize_lang_exts(map)
  local keys = {}
  for k in pairs(map) do keys[#keys + 1] = k end
  table.sort(keys)
  local lines = { "{" }
  for _, k in ipairs(keys) do
    local exts = map[k]
    local quoted = {}
    for _, e in ipairs(exts) do quoted[#quoted + 1] = string.format("%q", e) end
    lines[#lines + 1] = string.format("  [%q]={%s},", k, table.concat(quoted, ","))
  end
  lines[#lines + 1] = "}"
  return table.concat(lines, "\n")
end

local function build_fn_transform_cmd()
  local stderr_file = vim.fn.tempname() .. ".sg_grep.err"
  M.stderr_file = stderr_file
  local src = string.format(FN_TEMPLATE,
    serialize_lang_exts(LANG_EXTS),
    string.format("%q", stderr_file))
  local loader = assert(loadstring(src), "sg_grep: failed to compile fn_transform_cmd")
  M.fn_transform_cmd = loader()
end

-- Populate LANG_EXTS from `rg --type-list` (sync, ~20ms). Falls back silently
-- if rg is missing or the call fails.
function M.setup()
  if vim.fn.executable("rg") == 1 then
    local ok, out = pcall(vim.fn.system, { "rg", "--type-list" })
    if ok and vim.v.shell_error == 0 and type(out) == "string" and #out > 0 then
      local parsed = parse_type_list(out)
      if next(parsed) then LANG_EXTS = parsed end
    end
  end
  build_fn_transform_cmd()
end

-- ---------------------------------------------------------------------------
-- Header: colorized reflection of the parsed query.
-- ---------------------------------------------------------------------------

local C = {
  path  = "\27[38;5;214m", -- orange
  neg   = "\27[38;5;203m", -- red
  lang  = "\27[38;5;141m", -- purple
  dir   = "\27[38;5;75m",  -- blue
  word  = "\27[38;5;186m", -- yellow
  case  = "\27[38;5;44m",  -- teal
  err   = "\27[38;5;196m", -- bright red
  dim   = "\27[38;5;245m", -- gray
  reset = "\27[0m",
}

local HINT_SHORT = C.dim ..
    "f:path  -f:path  l:ts  -l:lua  d:src  w:word  c:yes  " ..
    "(alt-? for help)" .. C.reset

local HINT_LONG = table.concat({
  C.dim .. "sg-grep syntax:" .. C.reset,
  "  " .. C.path .. "f:PATH" .. C.reset .. "    include paths matching PATH",
  "  " .. C.neg .. "-f:PATH" .. C.reset .. "   exclude paths matching PATH",
  "  " .. C.lang .. "l:LANG" .. C.reset ..
      "    only LANG files (ts, py, rs, ...); ANDs with f:",
  "  " .. C.neg .. "-l:LANG" .. C.reset .. "   exclude LANG files",
  "  " .. C.dir .. "d:DIR" .. C.reset .. "     search inside DIR (relative to cwd)",
  "  " .. C.word .. "w:WORD" .. C.reset .. "    match WORD with word boundaries",
  "  " .. C.case .. "c:yes" .. C.reset .. "     case-sensitive",
  C.dim .. "  alt-? toggles this help" .. C.reset,
}, "\n")

-- Soft-wrap a string at word boundaries to a max line width.
local function wrap(text, width)
  local lines, line = {}, ""
  for word in text:gmatch("%S+") do
    if line == "" then
      line = word
    elseif #line + 1 + #word <= width then
      line = line .. " " .. word
    else
      lines[#lines + 1] = line
      line = word
    end
  end
  if line ~= "" then lines[#lines + 1] = line end
  return lines
end

local function read_stderr(path)
  if not path or path == "" then return nil end
  local f = io.open(path, "rb")
  if not f then return nil end
  local content = f:read("*a") or ""
  f:close()
  if content == "" then return nil end
  -- Drop rg's noisy "Running with --debug..." advisory; keep meaningful lines.
  content = content:gsub("Running with %-%-debug[^\n]*\n?", "")
  content = content:gsub("^%s+", ""):gsub("%s+$", "")
  if content == "" then return nil end
  return content
end

local function format_err(err, width)
  if not err then return nil end
  local out = {}
  for raw_line in (err .. "\n"):gmatch("([^\n]*)\n") do
    if raw_line ~= "" then
      for _, w in ipairs(wrap(raw_line, math.max(20, width - 2))) do
        out[#out + 1] = C.err .. (#out == 0 and "! " or "  ") .. w .. C.reset
      end
    end
  end
  return table.concat(out, "\n")
end

function M.header_for(query, opts)
  opts = opts or {}
  local width = opts.width
      or tonumber(os.getenv("FZF_COLUMNS"))
      or tonumber(os.getenv("COLUMNS"))
      or 100
  local err
  if opts.stderr_file then err = read_stderr(opts.stderr_file) end
  local err_block = format_err(err, width)
  if opts.long then
    return (err_block and (err_block .. "\n") or "") .. HINT_LONG
  end
  local base
  if not query or query == "" then
    base = HINT_SHORT
  else
    local parts = {}
    for _, tok in ipairs(tokenize(query)) do
      local kind = classify(tok)
      if kind then
        local color = tok.negate and C.neg or C[kind]
        parts[#parts + 1] = color .. tok.raw .. C.reset
      else
        parts[#parts + 1] = tok.raw
      end
    end
    base = table.concat(parts, " ")
  end
  if err_block then
    return err_block .. "\n" .. base
  end
  return base
end

-- ---------------------------------------------------------------------------
-- Shell-command generators for fzf --bind values.
-- ---------------------------------------------------------------------------

local function interpreter_cmd(mode_arg)
  local this_file = debug.getinfo(1, "S").source:sub(2)
  local stderr = M.stderr_file or ""
  for _, exe in ipairs({ "luajit", "lua" }) do
    if vim.fn.executable(exe) == 1 then
      return string.format("%s %s %s %s {q}", exe, shellescape(this_file),
        shellescape(mode_arg), shellescape(stderr))
    end
  end
  local nvim = vim.v.progpath or "nvim"
  return string.format("%s -u NONE --headless -l %s %s %s {q}",
    shellescape(nvim), shellescape(this_file),
    shellescape(mode_arg), shellescape(stderr))
end

-- change:transform-header — re-renders the short header on every keystroke.
function M.header_shell_cmd() return interpreter_cmd("short") end
-- alt-?:transform-header — prints the multi-line help block.
function M.help_shell_cmd() return interpreter_cmd("long") end

-- ---------------------------------------------------------------------------
-- CLI entry point: `lua sg_grep.lua <mode> <stderr_file> <query>`
-- Guard on absence of the `vim` global so `require()` from nvim skips this.
-- ---------------------------------------------------------------------------

if not rawget(_G, "vim") and arg and arg[0] and arg[0]:match("sg_grep%.lua$") then
  local mode = arg[1] or "short"
  local stderr_file = arg[2] or ""
  local query = arg[3] or ""
  io.stdout:write(M.header_for(query, {
    long = (mode == "long"),
    stderr_file = stderr_file,
  }))
  io.stdout:write("\n")
  os.exit(0)
end

return M
