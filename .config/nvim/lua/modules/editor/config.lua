local config = {}

function config.nvim_colorizer()
  require 'colorizer'.setup {
    css = { rgb_fn = true; };
    scss = { rgb_fn = true; };
    sass = { rgb_fn = true; };
    stylus = { rgb_fn = true; };
    vim = { names = true; };
    tmux = { names = false; };
    'javascript';
    'javascriptreact';
    'typescript';
    'typescriptreact';
    html = {
      mode = 'foreground';
    }
  }
end

function config.vim_cursorwod()
  vim.api.nvim_command('augroup user_plugin_cursorword')
  vim.api.nvim_command('autocmd!')
  vim.api.nvim_command('autocmd FileType NvimTree,lspsagafinder,dashboard,vista let b:cursorword = 0')
  vim.api.nvim_command('autocmd WinEnter * if &diff || &pvw | let b:cursorword = 0 | endif')
  vim.api.nvim_command('autocmd InsertEnter * let b:cursorword = 0')
  vim.api.nvim_command('autocmd InsertLeave * let b:cursorword = 1')
  vim.api.nvim_command('augroup END')
end

function config.gitsigns()
   if not packer_plugins['plenary.nvim'].loaded then
    vim.cmd [[packadd plenary.nvim]]
  end
  require('gitsigns').setup {
    signs = {
      add = {hl = 'GitGutterAdd', text = '▋'},
      change = {hl = 'GitGutterChange',text= '▋'},
      delete = {hl= 'GitGutterDelete', text = '▋'},
      topdelete = {hl ='GitGutterDeleteChange',text = '▔'},
      changedelete = {hl = 'GitGutterChange', text = '▎'},
    },
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,

      ['n ]g'] = { expr = true, "&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'"},
      ['n [g'] = { expr = true, "&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'"},

      ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
      ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
      ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
      ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
      ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line()<CR>',

     -- Text objects
      ['o ih'] = ':<C-U>lua require"gitsigns".text_object()<CR>',
      ['x ih'] = ':<C-U>lua require"gitsigns".text_object()<CR>'
    },
  }
end

return config
