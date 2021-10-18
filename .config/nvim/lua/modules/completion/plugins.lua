local completion = {}
local conf = require('modules.completion.config')

completion['neovim/nvim-lspconfig'] = {
  event = 'BufReadPre',
  config = conf.nvim_lsp,
}

completion['williamboman/nvim-lsp-installer'] = {
  cmd = {'LspInstallInfo', 'LspInstall', 'LspUninstall', 'LspUninstallAll', 'LspInstallLog', 'LspPrintInstalled'},
  config = conf.nvim_lsp_installer,
}

completion['glepnir/lspsaga.nvim'] = {
  cmd = 'Lspsaga',
}

completion['hrsh7th/nvim-cmp'] = {
  event = 'InsertEnter',
  config = conf.nvim_cmp,
  requires = {{'hrsh7th/cmp-buffer', opt=true}, {'hrsh7th/cmp-nvim-lsp', opt=true}, {'neovim/nvim-lspconfig', opt=true}}
}

return completion
