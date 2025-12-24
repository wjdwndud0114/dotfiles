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

-- Setup LspAttach autocmd for on_attach behavior
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local bufnr = args.buf

    -- Call the enhance_attach function
    enhance_attach(client, bufnr)

    -- Special handling for ts_ls
    if client.name == 'ts_ls' then
      client.server_capabilities.documentFormattingProvider = false
      vim.keymap.set('n', '<leader>o', function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.removeUnusedImports" },
          },
        })
      end, { buffer = bufnr })
    end
  end,
})

local servers_root = vim.fn.stdpath('data') .. global.path_sep .. 'mason' .. global.path_sep .. 'bin' .. global.path_sep

-- Configure gopls
vim.lsp.config('gopls', {
  cmd = { servers_root .. 'gopls', "--remote=auto" },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  capabilities = capabilities,
  init_options = {
    usePlaceholders = true,
    completeUnimported = true,
  }
})

-- Configure rust_analyzer
vim.lsp.config('rust_analyzer', {
  cmd = { servers_root .. 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json', '.git' },
  capabilities = capabilities,
})

-- Configure lua_ls
vim.lsp.config('lua_ls', {
  cmd = { servers_root .. 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
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
  capabilities = capabilities,
})

-- Configure ts_ls
vim.lsp.config('ts_ls', {
  cmd = { servers_root .. 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
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
})

-- Configure pyright
vim.lsp.config('pyright', {
  cmd = { servers_root .. 'pyright-langserver', '--stdio', '--watch' },
  filetypes = { 'python' },
  root_markers = { 'pyrightconfig.json', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
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
})

-- Configure bashls
vim.lsp.config('bashls', {
  cmd = { servers_root .. 'bash-language-server', 'start' },
  filetypes = { 'sh', 'bash' },
  root_markers = { '.git' },
  capabilities = capabilities
})

-- Enable all configured LSP servers
vim.lsp.enable({
  'gopls',
  'rust_analyzer',
  'lua_ls',
  'ts_ls',
  'pyright',
  'bashls',
})
