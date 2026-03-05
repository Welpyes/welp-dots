return{
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "html" },
    },
  },
  {
    "ray-x/go.nvim",
    dependencies = {  -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- lsp_keymaps = false,
      -- other options
    },
    config = function(lp, opts)
      require("go").setup(opts)
      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
        require('go.format').goimports()
        end,
        group = format_sync_grp,
      })
    end,
    event = {"CmdlineEnter"},
    ft = {"go", 'gomod'},
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.window = {
        documentation = false,
      }
      return opts
    end,
  },
  -- {
  --   "github/copilot.vim",
  --   -- Lazy-load on specific commands/keys for performance
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   config = function()
  --     -- Run setup on load to enable autocompletion
  --     vim.cmd("Copilot setup")
  --
  --     -- Optional: Custom keymaps (accept suggestion with Ctrl+J, toggle with leader keys)
  --     vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
  --       expr = true,
  --       replace_keycodes = false,
  --     })
  --     vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>")
  --     vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>")
  --   end,
  -- },
  {
    "elkowar/yuck.vim",
    ft = "yuck",  -- Lazy-load only for Yuck files
    init = function()
      vim.filetype.add({
        extension = {
          yuck = "yuck",
        },
      })
    end,
  },
  -- {
  -- 'chomosuke/typst-preview.nvim',
  -- lazy = false, -- or ft = 'typst'
  -- version = '1.*',
  -- opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  -- },
}
