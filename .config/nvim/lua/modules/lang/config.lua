local config = {}

function config.nvim_treesitter()
  -- vim.api.nvim_command('set foldmethod=expr')
  -- vim.api.nvim_command('set foldexpr=nvim_treesitter#foldexpr()')
  local filetypes = {
    "markdown", "markdown_inline", "bash", "comment", "css", "dockerfile", "go", "graphql", "html",
    "http", "java", "javascript",
    "jsdoc", "json", "json5", "latex", "lua", "make", "perl", "python", "regex", "ruby", "rust", "scss", "tsx",
    "typescript", "vim", "yaml"
  }
  require('nvim-treesitter').install(filetypes)

  vim.api.nvim_create_autocmd('FileType', {
    pattern = filetypes,
    callback = function()
      vim.treesitter.start()
      vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      vim.wo[0][0].foldmethod = 'expr'
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

function config.nvim_treesitter_textobjects()
  require("nvim-treesitter-textobjects").setup {
    select = {
      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,
      -- You can choose the select mode (default is charwise 'v')
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * method: eg 'v' or 'o'
      -- and should return the mode ('v', 'V', or '<c-v>') or a table
      -- mapping query_strings to modes.
      selection_modes = {
        ['@parameter.outer'] = 'v', -- charwise
        ['@function.outer'] = 'V',  -- linewise
        ['@class.outer'] = '<c-v>', -- blockwise
      },
      -- If you set this to `true` (default is `false`) then any textobject is
      -- extended to include preceding or succeeding whitespace. Succeeding
      -- whitespace has priority in order to act similarly to eg the built-in
      -- `ap`.
      --
      -- Can also be a function which gets passed a table with the keys
      -- * query_string: eg '@function.inner'
      -- * selection_mode: eg 'v'
      -- and should return true of false
      include_surrounding_whitespace = false,
    },
  }
  vim.keymap.set({ "x", "o" }, "af", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@function.outer", "textobjects")
  end)
  vim.keymap.set({ "x", "o" }, "if", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@function.inner", "textobjects")
  end)
  vim.keymap.set({ "x", "o" }, "ac", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@class.outer", "textobjects")
  end)
  vim.keymap.set({ "x", "o" }, "ic", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@class.inner", "textobjects")
  end)
  vim.keymap.set({ "x", "o" }, "ab", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@block.outer", "textobjects")
  end)
  vim.keymap.set({ "x", "o" }, "ib", function()
    require "nvim-treesitter-textobjects.select".select_textobject("@block.inner", "textobjects")
  end)
end

return config
