local conf = require('modules.ui.config')

return {
  {
    'ellisonleao/gruvbox.nvim',
    lazy = false, -- Load immediately on startup
    priority = 1000, -- Load before other plugins
    dependencies = { 'rktjmp/lush.nvim' },
    config = function()
      require('gruvbox').setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = {
          strings = true,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true,
        contrast = "",
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
      vim.cmd('colorscheme gruvbox')
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    event = 'UIEnter',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = conf.lualine,
  },

  {
    'j-hui/fidget.nvim',
    event = 'LspAttach',
    config = conf.fidget,
  },

  {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufReadPost',
    main = 'ibl',
    config = conf.indent_blankline,
  },
}
