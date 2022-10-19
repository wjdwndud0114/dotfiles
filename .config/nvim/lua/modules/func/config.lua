local config = {}

function config.vimspector()
  vim.cmd [[packadd! vimspector]]
  vim.g.vimspector_install_gadgets = {
    "debugpy", -- Python
  }
end

return config
