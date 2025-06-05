local config = {}

function config.goose()
  -- install goose with `curl -fsSL https://github.com/block/goose/releases/download/stable/download_cli.sh | bash`
  require('goose').setup({
    prefered_picker = 'fzf',
    default_global_keymaps = true,
    keymap = {
      global = {
        toggle = '<leader>gg',                 -- Open goose. Close if opened
        open_input = '<leader>gi',             -- Opens and focuses on input window on insert mode
        open_input_new_session = '<leader>gI', -- Opens and focuses on input window on insert mode. Creates a new session
        open_output = '<leader>go',            -- Opens and focuses on output window
        toggle_focus = '<leader>gt',           -- Toggle focus between goose and last window
        close = '<leader>gq',                  -- Close UI windows
        toggle_fullscreen = '<leader>gf',      -- Toggle between normal and fullscreen mode
        select_session = '<leader>gs',         -- Select and load a goose session
        goose_mode_chat = '<leader>gmc',       -- Set goose mode to `chat`. (Tool calling disabled. No editor context besides selections)
        goose_mode_auto = '<leader>gma',       -- Set goose mode to `auto`. (Default mode with full agent capabilities)
        configure_provider = '<leader>gp',     -- Quick provider and model switch from predefined list
        diff_open = '<leader>gdd',             -- Opens a diff tab of a modified file since the last goose prompt
        diff_next = '<leader>g]',              -- Navigate to next file diff
        diff_prev = '<leader>g[',              -- Navigate to previous file diff
        diff_close = '<leader>gc',             -- Close diff view tab and return to normal editing
        diff_revert_all = '<leader>gra',       -- Revert all file changes since the last goose prompt
        diff_revert_this = '<leader>grt',      -- Revert current file changes since the last goose prompt
      },
      window = {
        submit = '<cr>',               -- Submit prompt (normal mode)
        submit_insert = '<cr>',        -- Submit prompt (insert mode)
        close = '<esc>',               -- Close UI windows
        stop = '<C-c>',                -- Stop goose while it is running
        next_message = ']]',           -- Navigate to next message in the conversation
        prev_message = '[[',           -- Navigate to previous message in the conversation
        mention_file = '@',            -- Pick a file and add to context. See File Mentions section
        toggle_pane = '<tab>',         -- Toggle between input and output panes
        prev_prompt_history = '<up>',  -- Navigate to previous prompt in history
        next_prompt_history = '<down>' -- Navigate to next prompt in history
      }
    },
  })
end

function config.nvim_lsp()
  require('modules.completion.lspconfig')
end

function config.mason_nvim()
  require('mason').setup()
end

function config.mason_lspconfig()
  require("mason-lspconfig").setup({
    ensure_installed = { "bashls", "pyright", "ts_ls", "lua_ls" }
  })
end

function config.nvim_cmp()
  local cmp = require 'cmp'
  cmp.setup({
    -- snippet = {
    --   expand = function(args)
    --     vim.fn["vsnip#anonymous"](args.body)
    --   end,
    -- },
    mapping = {
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ["<C-k>"] = cmp.mapping.select_prev_item(),
      ["<C-j>"] = cmp.mapping.select_next_item(),
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-u>'] = cmp.mapping.scroll_docs(4),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = "luasnip" },
      { name = 'buffer' },
    },
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
  });
end

function config.null_ls()
  -- hack to make this work for new nvim version
  vim.lsp._request_name_to_capability = vim.lsp.protocol._request_name_to_capability
  local null_ls = require('null-ls')

  null_ls.setup({
    on_attach = require('modules/completion/format').enhance_attach,
    sources = {
      -- Python
      -- null_ls.builtins.formatting.autopep8,
      -- null_ls.builtins.formatting.isort,
      -- null_ls.builtins.diagnostics.flake8,

      -- JS yaml html markdown
      null_ls.builtins.formatting.black,
      null_ls.builtins.diagnostics.mypy.with {
        method = null_ls.methods.DIAGNOSTICS_ON_SAVE,
        command = "mypy-daemon",
        args = function(params)
          return { "-s" }
        end
      },
      null_ls.builtins.formatting.prettierd,
      require('none-ls.diagnostics.eslint_d'),
      require('none-ls.formatting.eslint_d').with({
        prefer_local = "node_modules/.bin",
      }),
      null_ls.builtins.formatting.prettierd,
      -- null_ls.builtins.code_actions.gitsigns,

      -- C/C++
      -- Formatting is handled by clangd language server
      -- null_ls.builtins.formatting.clang_format,

      -- Markdown
      -- null_ls.builtins.diagnostics.markdownlint,

      -- Lua
      -- cargo install stylua
      -- add ~/.cargo/bin to PATH
      -- null_ls.builtins.formatting.stylua,

      -- Spell checking
      -- null_ls.builtins.diagnostics.codespell.with({
      --   args = { "--builtin", "clear,rare,code", "-" },
      -- }),
    },
  })
end

return config
