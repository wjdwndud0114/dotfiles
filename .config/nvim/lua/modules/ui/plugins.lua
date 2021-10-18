local ui = {}
local conf = require('modules.ui.config')

ui['ellisonleao/gruvbox.nvim'] = {
  requires = {"rktjmp/lush.nvim"},
  config = [[vim.cmd('colorscheme gruvbox')]],
}

ui['hoob3rt/lualine.nvim'] = {
  requires = {'kyazdani42/nvim-web-devicons', opt = true},
  config = conf.lualine,
}

ui['lukas-reineke/indent-blankline.nvim'] = {
  event = 'BufRead',
  config = conf.indent_blankline,
}

return ui
