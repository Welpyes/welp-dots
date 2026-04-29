return {
  {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
      require("mini.comment").setup()
      require("mini.surround").setup()
      require("mini.icons").setup()
      require("mini.keymap").setup()
      require("mini.align").setup()
      require("mini.move").setup()
      require("mini.tabline").setup()
      require("mini.basics").setup()
      require("mini.git").setup()
      require("mini.extra").setup()
    end,
  },
}
