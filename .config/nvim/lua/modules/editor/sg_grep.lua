-- Sourcegraph-style query syntax for fzf-lua live_grep.
--
-- Supported keywords (anywhere in the query, space-separated):
--   f:PATTERN      include only paths matching PATTERN
--   -f:PATTERN     exclude paths matching PATTERN
--   lang:NAME      restrict to ripgrep type NAME (ts, py, lua, ...)
--   -lang:NAME     exclude ripgrep type NAME
--   case:yes       case-sensitive (overrides --smart-case)
--   content:TEXT   literal (fixed-string) pattern; disables regex
--
-- Remaining bare tokens form the regex pattern.

local M = {}

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
      local start = i
      local negate = (c == "-")
      local buf = {}
      local in_quote = false
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
  f = "path", file = "path", path = "path",
  lang = "lang", language = "lang",
  ["case"] = "case",
  content = "content", literal = "content",
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

-- fn_transform_cmd must be SELF-CONTAINED (no upvalues): fzf-lua serializes
-- it via string.dump and reloads it in a headless nvim child, where
-- upvalues from the parent module are unreachable. All helpers and tables
-- below are re-declared inside the function body.
function M.fn_transform_cmd(query, cmd, _opts)
  -- Language name -> list of file extensions. When `lang:X` appears with
  -- any `f:` filter we fold the extensions into the path glob so rg
  -- intersects (rather than unions) the two filters. A bare `lang:X`
  -- with no `f:` falls back to `--type=X` which preserves rg's fuller
  -- alias set for unknown entries.
  local LANG_EXTS = {
    ts       = { "ts", "tsx", "cts", "mts" },
    js       = { "js", "jsx", "cjs", "mjs" },
    lua      = { "lua" },
    py       = { "py", "pyi" },
    python   = { "py", "pyi" },
    go       = { "go" },
    rs       = { "rs" },
    rust     = { "rs" },
    rb       = { "rb" },
    ruby     = { "rb" },
    java     = { "java" },
    kt       = { "kt", "kts" },
    kotlin   = { "kt", "kts" },
    swift    = { "swift" },
    c        = { "c", "h" },
    cpp      = { "cpp", "cc", "cxx", "hpp", "hh", "hxx", "h" },
    cc       = { "cpp", "cc", "cxx", "hpp", "hh", "hxx", "h" },
    cs       = { "cs" },
    csharp   = { "cs" },
    php      = { "php" },
    sh       = { "sh", "bash" },
    bash     = { "sh", "bash" },
    zsh      = { "zsh" },
    vim      = { "vim" },
    md       = { "md", "markdown" },
    markdown = { "md", "markdown" },
    html     = { "html", "htm" },
    css      = { "css" },
    scss     = { "scss" },
    json     = { "json" },
    yaml     = { "yaml", "yml" },
    yml      = { "yaml", "yml" },
    toml     = { "toml" },
    xml      = { "xml" },
    sql      = { "sql" },
    tex      = { "tex" },
    dart     = { "dart" },
    elm      = { "elm" },
    ex       = { "ex", "exs" },
    elixir   = { "ex", "exs" },
    erl      = { "erl", "hrl" },
    hs       = { "hs" },
    haskell  = { "hs" },
    scala    = { "scala", "sbt" },
    clj      = { "clj", "cljs", "cljc", "edn" },
    clojure  = { "clj", "cljs", "cljc", "edn" },
  }

  local function shellescape(s)
    return "'" .. (s:gsub("'", [['\'']])) .. "'"
  end
  local function tokenize(q)
    local tokens, i, n = {}, 1, #q
    while i <= n do
      local c = q:sub(i, i)
      if c:match("%s") then
        i = i + 1
      else
        local start, negate, buf, in_quote = i, (c == "-"), {}, false
        while i <= n do
          local ch = q:sub(i, i)
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
        tokens[#tokens + 1] = { raw = q:sub(start, i - 1), text = table.concat(buf), negate = negate }
      end
    end
    return tokens
  end
  local KEYWORDS = {
    f = "path", file = "path", path = "path",
    lang = "lang", language = "lang",
    ["case"] = "case",
    content = "content", literal = "content",
  }
  local function classify(tok)
    local body = tok.negate and tok.text:sub(2) or tok.text
    local key, val = body:match("^([%w_]+):(.*)$")
    if not key then return nil end
    local kind = KEYWORDS[key:lower()]
    if not kind then return nil end
    if val:sub(1, 1) == '"' and val:sub(-1) == '"' then val = val:sub(2, -2) end
    return kind, val
  end

  local path_incl, path_excl = {}, {}
  local lang_incl, lang_excl = {}, {}
  local pattern_parts = {}
  local literal, case_sensitive = false, false

  for _, tok in ipairs(tokenize(query)) do
    local kind, val = classify(tok)
    if kind == "path" and val ~= "" then
      local glob = val
      if not glob:find("[*?]") then glob = "*" .. glob .. "*" end
      if tok.negate then path_excl[#path_excl + 1] = glob
      else path_incl[#path_incl + 1] = glob end
    elseif kind == "lang" and val ~= "" then
      if tok.negate then lang_excl[#lang_excl + 1] = val:lower()
      else lang_incl[#lang_incl + 1] = val:lower() end
    elseif kind == "case" then
      if val:lower() == "yes" or val == "true" or val == "1" then case_sensitive = true end
    elseif kind == "content" then
      literal = true
      if val ~= "" then pattern_parts[#pattern_parts + 1] = val end
    elseif kind == nil then
      pattern_parts[#pattern_parts + 1] = tok.text
    end
  end

  -- Collect all extensions for include-langs (known ones only). If any
  -- lang is unknown we fall back to --type=LANG for that one.
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
    -- Fold extensions into each include path so we get AND semantics.
    local ext_group = "{" .. table.concat(incl_exts, ",") .. "}"
    for _, p in ipairs(path_incl) do
      -- Strip trailing "*" so the extension sits at end-of-filename.
      local base = p:gsub("%*+$", "")
      args[#args + 1] = "--iglob=" .. shellescape(base .. "." .. ext_group)
    end
  elseif #incl_exts > 0 then
    local ext_group = "{" .. table.concat(incl_exts, ",") .. "}"
    args[#args + 1] = "--iglob=" .. shellescape("*." .. ext_group)
  else
    for _, p in ipairs(path_incl) do
      args[#args + 1] = "--iglob=" .. shellescape(p)
    end
  end
  -- Unknown include langs: best effort, emit --type and let rg union.
  for _, lang in ipairs(unknown_incl_langs) do
    args[#args + 1] = "--type=" .. shellescape(lang)
  end
  for _, p in ipairs(path_excl) do
    args[#args + 1] = "--iglob=" .. shellescape("!" .. p)
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
  if literal then args[#args + 1] = "--fixed-strings" end

  local pat = table.concat(pattern_parts, " ")
  -- The previewer calls us with cmd=nil; it only reads the second return.
  if not cmd then return nil, pat end
  if pat == "" then
    -- Only filters, no search term yet: no-op so rg doesn't error.
    return "true", ""
  end
  local extra = table.concat(args, " ")
  local trimmed = cmd:gsub("%s+$", "")
  local new_cmd = trimmed
  if #extra > 0 then
    if trimmed:match(" %-e$") then
      new_cmd = trimmed:gsub(" %-e$", " " .. extra .. " -e")
    elseif trimmed:match(" %-%-$") then
      new_cmd = trimmed:gsub(" %-%-$", " " .. extra .. " --")
    else
      new_cmd = trimmed .. " " .. extra
    end
  end
  return new_cmd .. " " .. shellescape(pat), pat
end

-- Colorized header shown above the prompt. Re-rendered on every keystroke
-- via a `change:transform-header` fzf bind.
local C = {
  path    = "\27[38;5;214m", -- orange
  neg     = "\27[38;5;203m", -- red
  lang    = "\27[38;5;141m", -- purple
  case    = "\27[38;5;44m",  -- teal
  content = "\27[38;5;107m", -- green
  dim     = "\27[38;5;245m", -- gray
  reset   = "\27[0m",
}

local HINT = C.dim ..
    "f:path  -f:path  lang:ts  -lang:lua  case:yes  content:\"literal\"" ..
    C.reset

function M.header_for(query)
  if not query or query == "" then return HINT end
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
  return table.concat(parts, " ")
end

-- Shell command (for fzf --bind) that prints the header for an arbitrary
-- query. {q} is shell-escaped by fzf. Prefer luajit/lua for snappy output;
-- fall back to `nvim -l` which is always available but adds ~50ms.
function M.header_shell_cmd()
  local this_file = debug.getinfo(1, "S").source:sub(2)
  for _, exe in ipairs({ "luajit", "lua" }) do
    if vim.fn.executable(exe) == 1 then
      return string.format("%s %s {q}", exe, shellescape(this_file))
    end
  end
  local nvim = vim.v.progpath or "nvim"
  return string.format("%s -u NONE --headless -l %s {q}", shellescape(nvim), shellescape(this_file))
end

-- CLI entry point: `lua sg_grep.lua "query"` prints the colorized header.
-- Guard on the absence of the `vim` global so this only fires under plain
-- Lua / LuaJIT, not when Neovim `require`s this module.
if not rawget(_G, "vim") and arg and arg[0] and arg[0]:match("sg_grep%.lua$") then
  io.stdout:write(M.header_for(arg[1] or ""))
  io.stdout:write("\n")
  os.exit(0)
end

return M
