local conf = require('modules.lang.config')

return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    config = conf.nvim_treesitter,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    lazy = true,
    config = conf.nvim_treesitter_textobjects,
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = 'markdown',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = conf.render_markdown,
  },
}
