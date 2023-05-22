local config = {}

function config.nvim_treesitter()
  vim.api.nvim_command('set foldmethod=expr')
  vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
  require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "markdown", "markdown_inline", "bash", "comment", "css", "dockerfile", "go", "graphql", "html",
      "http", "java", "javascript",
      "jsdoc", "json", "json5", "latex", "lua", "make", "perl", "python", "regex", "ruby", "rust", "scss", "tsx",
      "typescript", "vim", "yaml" },
    highlight = {
      enable = true,
      disable = { "VimspectorPrompt" },
    },
    textobjects = {
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
          ["ab"] = "@block.outer",
          ["ib"] = "@block.inner",
        },
      },
    },
  }
end

return config
