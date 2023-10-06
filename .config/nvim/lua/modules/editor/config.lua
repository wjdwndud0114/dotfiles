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
      fzf_opts = { ['--nth'] = 2, ['--delimiter'] = fzf.utils.nbsp },
      previewer = 'builtin',
    })
  end, { noremap = true })

  vim.keymap.set('n', '<leader><C-p>', function()
    fzf.fzf_exec('fd -H --type f --strip-cwd-prefix | ~/.dotfiles/file-web-devicon', {
      actions = fzf.defaults.actions.files,
      cwd = vim.api.nvim_eval("expand('%:p:~:.:h')"),
      prompt = vim.api.nvim_eval("expand('%:p:~:.:h')") .. '> ',
      fzf_opts = { ['--nth'] = 2, ['--delimiter'] = fzf.utils.nbsp },
      previewer = 'builtin',
    })
  end, { noremap = true })

  vim.keymap.set('n', '<leader>s', function()
    fzf.fzf_live(
      'rg --column --line-number --no-heading --color=always --smart-case -- <query> | ~/.dotfiles/file-web-devicon', {
        actions = fzf.defaults.actions.files,
        prompt = 'Rg> ',
        fzf_opts = {
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
      add = { hl = 'GitGutterAdd', text = '▋' },
      change = { hl = 'GitGutterChange', text = '▋' },
      delete = { hl = 'GitGutterDelete', text = '▋' },
      topdelete = { hl = 'GitGutterDeleteChange', text = '▔' },
      changedelete = { hl = 'GitGutterChange', text = '▎' },
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map('n', ']g', function()
        if vim.wo.diff then return ']g' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, { expr = true })

      map('n', '[g', function()
        if vim.wo.diff then return '[g' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, { expr = true })

      -- Actions
      map('n', '<leader>hs', gs.stage_hunk)
      map('n', '<leader>hr', gs.reset_hunk)
      map('v', '<leader>hs', function() gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
      map('v', '<leader>hr', function() gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') } end)
      map('n', '<leader>hS', gs.stage_buffer)
      map('n', '<leader>hu', gs.undo_stage_hunk)
      map('n', '<leader>hR', gs.reset_buffer)
      map('n', '<leader>hp', gs.preview_hunk)
      map('n', '<leader>hb', function() gs.blame_line { full = true } end)
      map('n', '<leader>tb', gs.toggle_current_line_blame)
      map('n', '<leader>hd', gs.diffthis)
      map('n', '<leader>hD', function() gs.diffthis('~') end)
      map('n', '<leader>td', gs.toggle_deleted)

      -- Text object
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    end
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
