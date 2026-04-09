local os_name = vim.loop.os_uname().sysname
local path_sep = vim.loop.os_uname().sysname == 'Windows' and '\\' or '/'

local global = {
  is_mac = os_name == 'Darwin',
  is_linux = os_name == 'Linux',
  is_windows = os_name == 'Windows',
  vim_path = vim.fn.stdpath('config'),
  cache_dir = vim.fn.stdpath('cache') .. path_sep,
  data_dir = vim.fn.stdpath('data') .. path_sep,
  path_sep = path_sep,
  home = vim.loop.os_homedir(),
}

-- Derived paths
global.modules_dir = global.vim_path .. path_sep .. 'lua' .. path_sep .. 'modules'

return global
