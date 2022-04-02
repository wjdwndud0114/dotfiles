local api = vim.api
local lspconfig = require 'lspconfig'
local global = require 'core.global'
local format = require 'modules/completion/format'

if not packer_plugins['lspsaga.nvim'].loaded then
  vim.cmd [[packadd lspsaga.nvim]]
end

local saga = require 'lspsaga'
saga.init_lsp_saga({
  code_action_icon = '💡'
})

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
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

local enhance_attach = function(client,bufnr)
  if client.resolved_capabilities.document_formatting then
    format.lsp_before_save()
  end
  api.nvim_buf_set_option(0, "omnifunc", "v:lua.vim.lsp.omnifunc")
end

local servers_root = vim.fn.stdpath('data')..global.path_sep..'lsp_servers'..global.path_sep

-- lspconfig.gopls.setup {
--   cmd = {"gopls","--remote=auto"},
--   on_attach = enhance_attach,
--   capabilities = capabilities,
--   init_options = {
--     usePlaceholders=true,
--     completeUnimported=true,
--   }
-- }

local sumneko_root = servers_root..'sumneko_lua'..global.path_sep..'extension'..global.path_sep..'server'..global.path_sep
lspconfig.sumneko_lua.setup {
  cmd = {
    sumneko_root..'bin'..global.path_sep..'lua-language-server',
    "-E",
    sumneko_root..'main.lua'
  },
  settings = {
    Lua = {
      diagnostics = {
        -- enable = true,
        globals = {"vim","packer_plugins"}
      },
      runtime = {version = "LuaJIT"},
      workspace = {
        library = vim.list_extend({[vim.fn.expand("$VIMRUNTIME/lua")] = true},{}),
      },
    },
  },
  capabilities = capabilities,
}

lspconfig.tsserver.setup {
  cmd = { servers_root..'tsserver'..global.path_sep..'node_modules'..global.path_sep..'typescript-language-server'..global.path_sep..'lib'..global.path_sep..'cli.js', '--stdio' },
  on_attach = function(client, bufnr)
    -- disable tsserver format, but have autocmd for null-ls
    client.resolved_capabilities.document_formatting = false
    client.resolved_capabilities.document_range_formatting = false
    format.lsp_before_save()
    enhance_attach(client)
  end,
  flags = {
    debounce_text_changes = 150,
  },
  capabilities = capabilities,
}

lspconfig.pyright.setup {
  cmd = {
    servers_root..'python'..global.path_sep..'node_modules'..global.path_sep..'.bin'..global.path_sep..'pyright-langserver',
    '--stdio'
  },
  on_attach = enhance_attach,
  capabilities = capabilities,
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

local servers = {
  -- 'dockerls',
  'bashls',
}

for _,server in ipairs(servers) do
  lspconfig[server].setup {
    on_attach = enhance_attach,
    capabilities = capabilities
  }
end
