local conf = require('modules.completion.config')

return {
  {
    'github/copilot.vim',
    event = 'VeryLazy',
  },

  {
    'williamboman/mason.nvim',
    lazy = false, -- Load immediately to ensure LSP servers available
    config = conf.mason_nvim,
  },

  {
    'williamboman/mason-lspconfig.nvim',
    lazy = false,
    dependencies = { 'mason.nvim' },
    config = conf.mason_lspconfig,
  },

  {
    'neovim/nvim-lspconfig',
    event = 'BufReadPost',
    dependencies = {
      'mason.nvim',
      'mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = conf.nvim_lsp,
  },

  {
    'glepnir/lspsaga.nvim',
    cmd = 'Lspsaga',
  },

  {
    'L3MON4D3/LuaSnip',
    event = 'InsertEnter',
    build = vim.fn.executable('make') == 1 and 'make install_jsregexp' or nil,
  },

  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp',
      'saadparwaiz1/cmp_luasnip',
      'L3MON4D3/LuaSnip',
    },
    config = conf.nvim_cmp,
  },

  {
    'nvimtools/none-ls.nvim',
    event = 'LspAttach',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvimtools/none-ls-extras.nvim',
    },
    config = conf.null_ls,
  },
}
