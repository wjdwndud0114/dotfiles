local conf = require('modules.editor.config')

return {
  {
    'itchyny/vim-cursorword',
    event = { 'BufReadPre', 'BufNewFile' },
    config = conf.vim_cursorword,
  },

  {
    'norcalli/nvim-colorizer.lua',
    ft = { 'html', 'css', 'sass', 'vim', 'typescript', 'typescriptreact' },
    config = conf.nvim_colorizer,
  },

  {
    'ibhagwan/fzf-lua',
    keys = {
      { '<C-p>',             desc = 'Find files' },
      { '<leader><C-p>',     desc = 'Find files (relative)' },
      { '<leader>s',         desc = 'Live grep' },
      { '<leader><leader>s', desc = 'Live grep (relative)' },
      { '<leader>b',         desc = 'Buffers' },
    },
    dependencies = {
      'vijaymarupudi/nvim-fzf',
      'nvim-tree/nvim-web-devicons',
    },
    config = conf.fzf_lua,
  },

  { 'tpope/vim-surround',   event = { 'BufReadPost', 'BufNewFile' } },
  { 'tpope/vim-repeat',     event = { 'BufReadPost', 'BufNewFile' } },
  { 'tpope/vim-commentary', event = { 'BufReadPost', 'BufNewFile' } },
  { 'tpope/vim-fugitive',   cmd = { 'Git', 'G', 'Gstatus', 'Gdiff', 'Gblame' } },

  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = conf.gitsigns,
  },

  {
    'rmagatti/auto-session',
    lazy = false, -- Must load on startup to restore session
    config = conf.auto_session,
  },
}
