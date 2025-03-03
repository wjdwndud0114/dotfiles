local config = {}

function config.copilot_chat()
  require("CopilotChat").setup()
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
      null_ls.builtins.diagnostics.eslint_d,
      null_ls.builtins.formatting.eslint_d.with({
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
