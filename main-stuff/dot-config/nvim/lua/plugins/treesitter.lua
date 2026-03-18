return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    indent = {
      enable = true,
      disable = { "lisp", "fennel", "yuck" },
    },
  },
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
      },
    },
  },
}
