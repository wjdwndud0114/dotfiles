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
  local group = vim.api.nvim_create_augroup('user_plugin_cursorword', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = { 'NvimTree', 'lspsagafinder', 'dashboard', 'vista' },
    callback = function() vim.b.cursorword = 0 end,
  })
  vim.api.nvim_create_autocmd('WinEnter', {
    group = group,
    callback = function()
      if vim.wo.diff or vim.wo.previewwindow then
        vim.b.cursorword = 0
      end
    end,
  })
  vim.api.nvim_create_autocmd('InsertEnter', {
    group = group,
    callback = function() vim.b.cursorword = 0 end,
  })
  vim.api.nvim_create_autocmd('InsertLeave', {
    group = group,
    callback = function() vim.b.cursorword = 1 end,
  })
end

function config.fzf_lua()
  -- https://github.com/ibhagwan/fzf-lua/wiki/Advanced#fzf-exec-api
  -- speed up icon: https://github.com/MaartenStaa/file-web-devicons
  local fzf = require('fzf-lua')
  fzf.register_ui_select()

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
    fzf.live_grep()
  end, { noremap = true, desc = 'Live grep (Ctrl-G to toggle)' })

  vim.keymap.set('n', '<leader>b', function()
    fzf.buffers()
  end, { noremap = true, silent = true })
end

function config.gitsigns()
  require('gitsigns').setup {
    signs = {
      add = { text = '▋' },
      change = { text = '▋' },
      delete = { text = '▋' },
      topdelete = { text = '▔' },
      changedelete = { text = '▎' },
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

return config
