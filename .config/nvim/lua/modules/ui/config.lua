local config = {}

function config.lualine()
  require 'lualine'.setup {
    options = { theme = 'gruvbox' },
    sections = {
      lualine_b = { 'diff', { 'diagnostics', sources = { 'nvim_lsp', 'coc' } } },
      lualine_c = { 'filename' },
      lualine_y = {},
    },
  }
end

function config.fidget()
  require 'fidget'.setup {}
end

function config.indent_blankline()
  require('ibl').setup({
    indent = { char = "│", tab_char = "▏" },
    scope = {
      show_start = false,
      show_end = false,
    },
    exclude = {
      filetypes = {
        "startify",
        "dashboard",
        "dotooagenda",
        "log",
        "fugitive",
        "gitcommit",
        "packer",
        "vimwiki",
        "markdown",
        "json",
        "txt",
        "vista",
        "help",
        "todoist",
        "NvimTree",
        "peekaboo",
        "git",
        "TelescopePrompt",
        "undotree",
        "flutterToolsOutline",
        "" -- for all buffers without a file type
      },
      buftypes = { "terminal", "nofile" }
    }
  })
end

return config
