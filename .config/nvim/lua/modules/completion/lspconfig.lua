local lspconfig = require 'lspconfig'
local global = require 'core.global'

local enhance_attach = require('modules/completion/format').enhance_attach

if not packer_plugins['lspsaga.nvim'].loaded then
  vim.cmd [[packadd lspsaga.nvim]]
end

require('lspsaga').setup({
  finder = {
    keys = {
      vsplit = 'v',
      split = 's',
    }
  }
})

-- configure signs icons
local signs = {
  DiagnosticSignError = " ",
  DiagnosticSignWarn = " ",
  DiagnosticSignHint = " ",
  DiagnosticSignInfo = " ",
}

for hl, icon in pairs(signs) do
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true

function _G.reload_lsp()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
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

lspconfig.tsserver.setup {
  cmd = { servers_root .. 'typescript-language-server', '--stdio' },
  on_attach = function(client, bufnr)
    -- use null-ls & eslint_d for formatting
    client.server_capabilities.documentFormattingProvider = false
    enhance_attach(client, bufnr)
  end,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
  init_options = {
    hostInfo = "neovim",
    preferences = {
      importModuleSpecifierPreference = "non-relative",
    },
  },
}

lspconfig.pyright.setup {
  cmd = {
    servers_root .. 'pyright-langserver', '--stdio', '--watch'
  },
  root_dir = require('lspconfig/util').root_pattern("pyrightconfig.json", ".git", "pyproject.toml", "requirements.txt"),
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
