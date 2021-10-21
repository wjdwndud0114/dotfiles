local config = {}

function config.nvim_lsp()
  require('modules.completion.lspconfig')
end

function config.nvim_lsp_installer()
  require'nvim-lsp-installer'.on_server_ready(
  function(server)
    local opts = {}
    -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
    server:setup(opts)
    vim.cmd [[ do User LspAttachBuffers ]]
  end
  )
end

function config.nvim_cmp()
  local cmp = require'cmp'
  cmp.setup({
    snippet = {
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
      { name = 'nvim_lsp' },
      -- { name = 'vsnip' },
      { name = 'buffer' },
    }
  });
end

function config.null_ls()
  local null_ls = require('null-ls')
  null_ls.config({
    sources = {
      -- Python
      null_ls.builtins.formatting.autopep8,
      null_ls.builtins.formatting.isort,
      null_ls.builtins.diagnostics.flake8,

      -- JS yaml html markdown
      null_ls.builtins.formatting.prettier,

      -- C/C++
      -- Formatting is handled by clangd language server
      -- null_ls.builtins.formatting.clang_format,

      -- Markdown
      null_ls.builtins.diagnostics.markdownlint,

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
  require('lspconfig')['null-ls'].setup {
    on_attach = function (client,bufnr)
      if client.resolved_capabilities.document_formatting then
        require('modules.completion.format').lsp_before_save()
      end
      vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
    end
  }
end

return config
