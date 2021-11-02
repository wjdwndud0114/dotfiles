local completion = {}
local conf = require('modules.completion.config')

completion['neovim/nvim-lspconfig'] = {
  after = 'cmp-nvim-lsp',
  config = conf.nvim_lsp,
  requires = {
    {'nvim-lua/lsp-status.nvim'},
  },
}

completion['williamboman/nvim-lsp-installer'] = {
  cmd = {'LspInstallInfo', 'LspInstall', 'LspUninstall', 'LspUninstallAll', 'LspInstallLog', 'LspPrintInstalled'},
  config = conf.nvim_lsp_installer,
}

completion['tami5/lspsaga.nvim'] = {
  cmd = 'Lspsaga',
}

completion['L3MON4D3/LuaSnip'] = {}

completion['hrsh7th/nvim-cmp'] = {
  event = 'BufReadPre',
  -- event = 'InsertEnter',
  config = conf.nvim_cmp,
  requires = {
    {'hrsh7th/cmp-buffer', after='nvim-cmp'},
    {'hrsh7th/cmp-nvim-lsp', after='nvim-cmp'},
    {'saadparwaiz1/cmp_luasnip', after = 'LuaSnip'},
  }
}

completion['jose-elias-alvarez/null-ls.nvim'] = {
  event = 'BufReadPost',
  config = conf.null_ls,
  requires = {{"neovim/nvim-lspconfig", opt=true}, {"nvim-lua/plenary.nvim", opt=true }},
}

return completion
