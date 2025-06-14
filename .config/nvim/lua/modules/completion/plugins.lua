local completion = {}
local conf = require('modules.completion.config')

completion['github/copilot.vim'] = {}



completion['azorng/goose.nvim'] = {
  requires = { "nvim-lua/plenary.nvim",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        anti_conceal = { enabled = false },
      },
    }
  },
  config = conf.goose,
}

completion['neovim/nvim-lspconfig'] = {
  after = 'cmp-nvim-lsp',
  config = conf.nvim_lsp,
}

completion['williamboman/mason.nvim'] = {
  cmd = { 'LspInstall', 'LspUninstall', 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonUninstallAll', 'MasonLog' },
  config = conf.mason_nvim,
}

completion['williamboman/mason-lspconfig.nvim'] = {
  after = 'mason.nvim',
  cmd = { 'LspInstall', 'LspUninstall', 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonUninstallAll', 'MasonLog' },
  config = conf.mason_lspconfig,
}

completion['glepnir/lspsaga.nvim'] = {
  cmd = 'Lspsaga',
}

completion['L3MON4D3/LuaSnip'] = {}

completion['hrsh7th/nvim-cmp'] = {
  event = 'BufReadPre',
  -- event = 'InsertEnter',
  config = conf.nvim_cmp,
  requires = {
    { 'hrsh7th/cmp-buffer',       after = 'nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp',     after = 'nvim-cmp' },
    { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp', opt = true },
  }
}

completion['nvimtools/none-ls-extras.nvim'] = {
  before = 'nvimtools/none-ls.nvim',
}

completion['nvimtools/none-ls.nvim'] = {
  event = 'BufReadPost',
  config = conf.null_ls,
  requires = { { "nvim-lua/plenary.nvim" } },
}

return completion
