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

return config
