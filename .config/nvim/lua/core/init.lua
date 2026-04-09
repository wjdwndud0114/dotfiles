local global = require('core.global')

-- Create cache directories
local function createdir()
  local data_dirs = {
    global.cache_dir .. 'backup',
    global.cache_dir .. 'session',
    global.cache_dir .. 'swap',
    global.cache_dir .. 'tags',
    global.cache_dir .. 'undo'
  }

  for _, dir in ipairs(data_dirs) do
    vim.fn.mkdir(dir, 'p')
  end
end

local function load_core()
  createdir()

  require('core.options')
  require('core.mapping')
  require('keymap')
  require('core.event')
  require('core.filetype')

  -- Setup lazy.nvim
  require('core.lazy').setup()
end

load_core()
