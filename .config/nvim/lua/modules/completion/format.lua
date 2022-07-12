local format = {}

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

function format.lsp_before_save(bufnr)
  vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    buffer = bufnr,
    callback = function()
      vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
    end,
  })
end

return format
