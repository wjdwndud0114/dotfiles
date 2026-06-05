local M = {}

local SOURCEGRAPH_BASE_URL = 'https://dropbox.sourcegraphcloud.com'

local function read_file(path)
  local f = io.open(path, 'rb')
  if not f then return nil end
  local content = f:read('*a')
  f:close()
  return content
end

local function trim(s)
  return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function dirname(path)
  local parent = path:gsub('/+$', ''):match('^(.*)/[^/]*$')
  if parent == '' then return '/' end
  return parent
end

local function is_absolute(path)
  return path:sub(1, 1) == '/'
end

local function normalize_path(path)
  return vim.fn.fnamemodify(path, ':p'):gsub('/+$', '')
end

local function join_path(base, path)
  if is_absolute(path) then return normalize_path(path) end
  return normalize_path(base .. '/' .. path)
end

local function find_git_marker(start_path)
  local dir = normalize_path(start_path)
  while dir and dir ~= '' do
    local marker = dir .. '/.git'
    if vim.fn.isdirectory(marker) == 1 or vim.fn.filereadable(marker) == 1 then
      return marker, dir
    end

    local parent = dirname(dir)
    if parent == dir then break end
    dir = parent
  end
end

local function git_dirs_from_marker(marker)
  if vim.fn.isdirectory(marker) == 1 then
    return marker, marker
  end

  local marker_content = read_file(marker)
  if not marker_content then return nil end

  local git_dir = marker_content:match('^gitdir:%s*([^\r\n]+)')
  if not git_dir then return nil end

  git_dir = join_path(dirname(marker), trim(git_dir))

  local common_dir = git_dir
  local common_dir_content = read_file(git_dir .. '/commondir')
  if common_dir_content then
    common_dir = join_path(git_dir, trim(common_dir_content:match('^[^\r\n]+') or ''))
  end

  return git_dir, common_dir
end

local function config_remote_urls(config)
  local remotes = {}
  local current_remote

  for line in config:gmatch('[^\r\n]+') do
    line = trim(line)

    local remote = line:match('^%[remote%s+"([^"]+)"%]$')
    if remote then
      current_remote = remote
    elseif line:match('^%[') then
      current_remote = nil
    elseif current_remote then
      local key, value = line:match('^([%w%-%.]+)%s*=%s*(.-)%s*$')
      if key == 'url' and value and value ~= '' then
        remotes[#remotes + 1] = { name = current_remote, url = value }
      end
    end
  end

  return remotes
end

local function choose_remote_url(git_dir, common_dir)
  local remotes = {}

  for _, config_path in ipairs({
    common_dir .. '/config',
    git_dir .. '/config',
    git_dir .. '/config.worktree',
  }) do
    local config = read_file(config_path)
    if config then
      for _, remote in ipairs(config_remote_urls(config)) do
        remotes[#remotes + 1] = remote
      end
    end
  end

  for _, remote in ipairs(remotes) do
    if remote.name == 'origin' and remote.url:find('github%.com') then
      return remote.url
    end
  end

  for _, remote in ipairs(remotes) do
    if remote.name == 'origin' then
      return remote.url
    end
  end

  for _, remote in ipairs(remotes) do
    if remote.url:find('github%.com') then
      return remote.url
    end
  end

  return remotes[1] and remotes[1].url or nil
end

local function repo_from_remote_url(url)
  url = trim(url):gsub('%.git$', ''):gsub('/+$', '')

  local host, repo_path = url:match('^[^@/]+@([^:]+):(.+)$')
  if not host then
    local authority, path = url:match('^[%w+.-]+://([^/]+)/(.+)$')
    if authority and path then
      host = authority:gsub('^.*@', ''):gsub(':%d+$', '')
      repo_path = path
    end
  end

  if not host then
    host, repo_path = url:match('^([^/]+)/(.+)$')
  end

  if not host or not repo_path then return nil end
  return host .. '/' .. repo_path:gsub('%.git$', ''):gsub('/+$', '')
end

local function relative_path(path, root)
  path = normalize_path(path)
  root = normalize_path(root)

  if path == root then return '' end
  local prefix = root .. '/'
  if path:sub(1, #prefix) == prefix then
    return path:sub(#prefix + 1)
  end
end

local function encode_path(path)
  return path:gsub('([^%w%-%._~/])', function(c)
    return string.format('%%%02X', string.byte(c))
  end)
end

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.WARN, { title = 'Sourcegraph' })
end

local function open_url(url)
  if vim.ui and vim.ui.open then
    local ok = pcall(vim.ui.open, url)
    if ok then return end
  end

  local job = vim.fn.jobstart({ 'open', url }, { detach = true })
  if job <= 0 then
    notify('Failed to open Sourcegraph URL', vim.log.levels.ERROR)
  end
end

function M.open_current_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then
    notify('Current buffer has no file path')
    return
  end

  file = normalize_path(file)
  local marker, root = find_git_marker(dirname(file))
  if not marker then
    notify('Could not find a .git marker for current file')
    return
  end

  local git_dir, common_dir = git_dirs_from_marker(marker)
  if not git_dir or not common_dir then
    notify('Could not read git metadata for current file')
    return
  end

  local remote_url = choose_remote_url(git_dir, common_dir)
  if not remote_url then
    notify('Could not find a git remote URL')
    return
  end

  local sourcegraph_repo = repo_from_remote_url(remote_url)
  if not sourcegraph_repo then
    notify('Could not parse git remote URL: ' .. remote_url)
    return
  end

  local file_path = relative_path(file, root)
  if not file_path then
    notify('Current file is not under repository root')
    return
  end

  local line = vim.api.nvim_win_get_cursor(0)[1]
  if line < 1 then line = 1 end

  local url = string.format(
    '%s/%s/-/blob/%s?L%d',
    SOURCEGRAPH_BASE_URL,
    sourcegraph_repo,
    encode_path(file_path),
    line
  )
  open_url(url)
end

return M
