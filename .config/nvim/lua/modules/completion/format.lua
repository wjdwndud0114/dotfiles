local format = {}

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local function lsp_before_save(bufnr)
  vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
    end,
  })
end

function format.enhance_attach(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    lsp_before_save(bufnr)
  end
  vim.api.nvim_buf_set_option(0, "omnifunc", "v:lua.vim.lsp.omnifunc")
end

return format
