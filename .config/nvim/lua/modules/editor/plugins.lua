local editor = {}
local conf = require('modules.editor.config')

editor['itchyny/vim-cursorword'] = {
  event = { 'BufReadPre', 'BufNewFile' },
  config = conf.vim_cursorword
}

editor['norcalli/nvim-colorizer.lua'] = {
  ft = { 'html', 'css', 'sass', 'vim', 'typescript', 'typescriptreact' },
  config = conf.nvim_colorizer
}

editor['ibhagwan/fzf-lua'] = {
  requires = {
    'vijaymarupudi/nvim-fzf',
    'kyazdani42/nvim-web-devicons' -- optional for icons
  }
}

editor['tpope/vim-surround'] = {}

editor['tpope/vim-repeat'] = {}

editor['tpope/vim-commentary'] = {}

editor['tpope/vim-fugitive'] = {}

editor['lewis6991/gitsigns.nvim'] = {
  event = 'BufReadPre',
  config = conf.gitsigns,
  requires = { 'nvim-lua/plenary.nvim', opt = true },
  -- tag = 'release' -- To use the latest release
}

editor['rmagatti/auto-session'] = {
  config = conf.auto_session
}

return editor
