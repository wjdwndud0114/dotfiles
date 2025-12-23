local lang = {}
local conf = require('modules.lang.config')

lang['nvim-treesitter/nvim-treesitter'] = {
  config = conf.nvim_treesitter,
  build = ':TSUpdate',
  branch = 'main',
}

lang['nvim-treesitter/nvim-treesitter-textobjects'] = {
  after = 'nvim-treesitter',
  config = conf.nvim_treesitter_textobjects,
  branch = 'main',
}

return lang
