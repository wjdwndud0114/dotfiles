local config = {}

function config.nvim_colorizer()
  require 'colorizer'.setup {
    css = { rgb_fn = true, },
    scss = { rgb_fn = true, },
    sass = { rgb_fn = true, },
    stylus = { rgb_fn = true, },
    vim = { names = true, },
    tmux = { names = false, },
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    html = {
      mode = 'foreground',
    }
  }
end

function config.vim_cursorword()
  vim.api.nvim_command('augroup user_plugin_cursorword')
  vim.api.nvim_command('autocmd!')
  vim.api.nvim_command('autocmd FileType NvimTree,lspsagafinder,dashboard,vista let b:cursorword = 0')
  vim.api.nvim_command('autocmd WinEnter * if &diff || &pvw | let b:cursorword = 0 | endif')
  vim.api.nvim_command('autocmd InsertEnter * let b:cursorword = 0')
  vim.api.nvim_command('autocmd InsertLeave * let b:cursorword = 1')
  vim.api.nvim_command('augroup END')
end

function config.fzf_lua()
  -- https://github.com/ibhagwan/fzf-lua/wiki/Advanced#fzf-exec-api
  -- speed up icon: https://github.com/MaartenStaa/file-web-devicons
  local fzf = require('fzf-lua')

  vim.keymap.set('n', '<C-p>', function()
    fzf.fzf_exec('fd -H --type f --strip-cwd-prefix | ~/.dotfiles/file-web-devicon', {
      actions = fzf.defaults.actions.files,
      fzf_opts = {
        ['--multi'] = 999,
        ['--nth'] = 2,
        ['--delimiter'] = fzf.utils.nbsp
      },
      previewer = 'builtin',
    })
  end, { noremap = true })

  vim.keymap.set('n', '<leader><C-p>', function()
    fzf.fzf_exec('fd -H --type f --strip-cwd-prefix | ~/.dotfiles/file-web-devicon', {
      actions = fzf.defaults.actions.files,
      cwd = vim.api.nvim_eval("expand('%:p:~:.:h')"),
      prompt = vim.api.nvim_eval("expand('%:p:~:.:h')") .. '> ',
      fzf_opts = {
        ['--multi'] = 999,
        ['--nth'] = 2,
        ['--delimiter'] = fzf.utils.nbsp
      },
      previewer = 'builtin',
    })
  end, { noremap = true })

  vim.keymap.set('n', '<leader>s', function()
    fzf.fzf_live(
      'rg --column --line-number --no-heading --color=always --smart-case -- <query> | ~/.dotfiles/file-web-devicon', {
        actions = fzf.defaults.actions.files,
        prompt = 'Rg> ',
        fzf_opts = {
          ['--multi'] = 999,
          ['--nth'] = 2,
          ['--delimiter'] = fzf.utils.nbsp
        },
        previewer = 'builtin',
      })
  end, { noremap = true })

  vim.keymap.set('n', '<leader><leader>s', function()
    fzf.fzf_live(
      'rg --column --line-number --no-heading --color=always --smart-case -- <query> | ~/.dotfiles/file-web-devicon', {
        actions = fzf.defaults.actions.files,
        cwd = vim.api.nvim_eval("expand('%:p:~:.:h')"),
        prompt = vim.api.nvim_eval("expand('%:p:~:.:h')") .. ' Rg> ',
        fzf_opts = {
          ['--multi'] = 999,
          ['--nth'] = 2,
          ['--delimiter'] = fzf.utils.nbsp
        },
        previewer = 'builtin',
      })
  end, { noremap = true })
end

function config.gitsigns()
  if not packer_plugins['plenary.nvim'].loaded then
    vim.cmd [[packadd plenary.nvim]]
  end
  require('gitsigns').setup {
    signs = {
      add = { text = '▋' },
      change = { text = '▋' },
      delete = { text = '▋' },
      topdelete = { text = '▔' },
      changedelete = { text = '▎' },
    },
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,
      ['n ]g'] = { expr = true, "&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'" },
      ['n [g'] = { expr = true, "&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'" },
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

function config.auto_session()
  require('auto-session').setup()
end

-- function config.symbols_outline()
--   require("symbols-outline").setup(
--     {
--       highlight_hovered_item = true,
--       show_guides = true,
--       auto_preview = false,
--       position = 'right',
--       keymaps = {
--         close = { "<Esc>", "q" },
--         goto_location = "<Cr>",
--         focus_location = "o",
--         hover_symbol = "<C-space>",
--         toggle_preview = "K",
--         rename_symbol = "r",
--         code_actions = "a",
--         fold = "h",
--         unfold = "l",
--         fold_all = "W",
--         unfold_all = "E",
--         fold_reset = "R",
--       },
--       lsp_blacklist = {},
--     }
--   )
-- end

return config
