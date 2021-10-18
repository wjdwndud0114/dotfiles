local ui = {}
local conf = require('modules.ui.config')

ui['ellisonleao/gruvbox.nvim'] = {
  requires = {"rktjmp/lush.nvim"},
  config = [[vim.cmd('colorscheme gruvbox')]],
}

ui['famiu/feline.nvim'] = {
  config = conf.feline,
  requires = 'kyazdani42/nvim-web-devicons',
}

ui['lukas-reineke/indent-blankline.nvim'] = {
  event = 'BufRead',
  config = conf.indent_blankline,
}

return ui
