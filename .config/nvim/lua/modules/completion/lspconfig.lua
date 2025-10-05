local lspconfig = require 'lspconfig'
local global = require 'core.global'

local enhance_attach = require('modules/completion/format').enhance_attach

if not packer_plugins['lspsaga.nvim'].loaded then
  vim.cmd [[packadd lspsaga.nvim]]
end

-- needed for some reason for line diagnostics for lspsaga
vim.diagnostic.config({
  severity_sort = true,
})

require('lspsaga').setup({
  finder = {
    keys = {
      vsplit = 'v',
      split = 's',
    }
  }
})

-- configure signs icons
vim.diagnostic.config({
  text = {
    [vim.diagnostic.severity.ERROR] = " ",
    [vim.diagnostic.severity.WARN] = " ",
    [vim.diagnostic.severity.INFO] = "󰋼 ",
    [vim.diagnostic.severity.HINT] = "󰌵 ",
  },
  numhl = {
    [vim.diagnostic.severity.ERROR] = "",
    [vim.diagnostic.severity.WARN] = "",
    [vim.diagnostic.severity.HINT] = "",
    [vim.diagnostic.severity.INFO] = "",
  },
})

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

function _G.reload_lsp()
  vim.lsp.stop_client(vim.lsp.get_clients())
  vim.cmd [[edit]]
end

function _G.open_lsp_log()
  local path = vim.lsp.get_log_path()
  vim.cmd("edit " .. path)
end

vim.cmd('command! -nargs=0 LspLog call v:lua.open_lsp_log()')
vim.cmd('command! -nargs=0 LspRestart call v:lua.reload_lsp()')

vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    -- Enable underline, use default values
    underline = true,
    -- Enable virtual text, override spacing to 4
    virtual_text = true,
    signs = {
      enable = true,
      priority = 20
    },
    -- Disable a feature
    update_in_insert = false,
  })

local servers_root = vim.fn.stdpath('data') .. global.path_sep .. 'mason' .. global.path_sep .. 'bin' .. global.path_sep

lspconfig.gopls.setup {
  cmd = {
    servers_root .. 'gopls', "--remote=auto" },
  on_attach = enhance_attach,
  capabilities = capabilities,
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
  }
}

lspconfig.rust_analyzer.setup {
  cmd = {
    servers_root .. 'rust-analyzer',
  },
  on_attach = enhance_attach,
  capabilities = capabilities,
}

lspconfig.lua_ls.setup {
  cmd = {
    servers_root .. 'lua-language-server',
  },
  settings = {
    Lua = {
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
        }
      },
      diagnostics = {
        -- enable = true,
        globals = { "vim", "packer_plugins" },
        neededFileStatus = {
          ["codestyle-check"] = "Any"
        }
      },
      runtime = { version = "LuaJIT" },
      workspace = {
        library = vim.list_extend({ [vim.fn.expand("$VIMRUNTIME/lua")] = true }, {}),
      },
    },
  },
  on_attach = function(client, bufnr)
    enhance_attach(client, bufnr)
  end,
  capabilities = capabilities,
}

lspconfig.ts_ls.setup {
  cmd = { servers_root .. 'typescript-language-server', '--stdio' },
  on_attach = function(client, bufnr)
    -- use null-ls & eslint_d for formatting
    client.server_capabilities.documentFormattingProvider = false
    enhance_attach(client, bufnr)
    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   group = vim.api.nvim_create_augroup("TS_add_missing_imports", { clear = true }),
    --   desc = "TS_add_missing_imports",
    --   pattern = { "*.ts", "*.tsx" },
    --   callback = function()
    --     vim.lsp.buf.code_action({
    --       apply = true,
    --       context = {
    --         only = { "source.addMissingImports" },
    --       },
    --     })
    --   end,
    -- })
    vim.keymap.set('n', '<leader>o', function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.removeUnusedImports" },
        },
      })
    end)
  end,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
  init_options = {
    hostInfo = "neovim",
    preferences = {
      includeCompletionsForModuleExports = true,
      includeCompletionsForImportStatements = true,
      importModuleSpecifierPreference = "non-relative",
    },
    maxTsServerMemory = 12288
  },
}

-- vim.lsp.set_log_level("debug")
lspconfig.pyright.setup {
  cmd = {
    servers_root .. 'pyright-langserver', '--stdio', '--watch'
  },
  root_dir = lspconfig.util.root_pattern("pyrightconfig.json", ".git"),
  on_attach = enhance_attach,
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "off",
        autoSearchPaths = true,
        useLibraryCodeForTypes = false,
        diagnosticMode = "openFilesOnly",
        autoImportCompletions = true,
      }
    }
  }
}

-- lspconfig.clangd.setup {
--   cmd = {
--     "clangd",
--     "--background-index",
--     "--suggest-missing-includes",
--     "--clang-tidy",
--     "--header-insertion=iwyu",
--   },
-- }

-- lspconfig.rust_analyzer.setup {
--   capabilities = capabilities,
-- }

lspconfig.bashls.setup {
  cmd = { servers_root .. 'bash-language-server' },
  on_attach = enhance_attach,
  capabilities = capabilities
}

local servers = {
  -- 'dockerls',
  -- 'bashls',
}

for _, server in ipairs(servers) do
  lspconfig[server].setup {
    on_attach = enhance_attach,
    capabilities = capabilities
  }
end
