local g = require('core.global')

local lazypath = g.data_dir .. "lazy/lazy.nvim"

-- Bootstrap lazy.nvim
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local lazy = {}

function lazy.setup()
  -- Discover all plugin specs from modules/*/plugins.lua
  local plugin_specs = {}

  local plugin_files = vim.fn.globpath(g.modules_dir, '*/plugins.lua', false, true)
  for _, file in ipairs(plugin_files) do
    local module_path = file:match("(modules/.*%.lua)$")
    if module_path then
      local spec = require(module_path:gsub("%.lua$", ""):gsub("/", "."))
      -- Flatten the spec table into plugin_specs array
      for _, plugin in ipairs(spec) do
        table.insert(plugin_specs, plugin)
      end
    end
  end

  require("lazy").setup(plugin_specs, {
    root = g.data_dir .. "lazy",
    defaults = {
      lazy = false, -- plugins are loaded on startup by default
    },
    install = {
      missing = true,
      colorscheme = { "gruvbox" },
    },
    checker = {
      enabled = false, -- don't check for updates automatically
    },
    change_detection = {
      enabled = true,
      notify = false, -- don't spam notifications
    },
    performance = {
      cache = {
        enabled = true,
      },
      rtp = {
        disabled_plugins = {
          "gzip",
          "matchit",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
    ui = {
      border = "rounded",
      icons = {
        cmd = "⌘",
        config = "🛠",
        event = "📅",
        ft = "📂",
        init = "⚙",
        keys = "🗝",
        plugin = "🔌",
        runtime = "💻",
        require = "🌙",
        source = "📄",
        start = "🚀",
        task = "📌",
        lazy = "💤 ",
      },
    },
  })
end

return lazy
