return {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter", -- Load only when entering insert mode for efficiency
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",     -- Source for LSP completions
    "hrsh7th/cmp-buffer",       -- Source for buffer text
    "hrsh7th/cmp-path",         -- Source for file system paths
    "L3MON4D3/LuaSnip",         -- Snippet engine
    "saadparwaiz1/cmp_luasnip", -- Snippet source for nvim-cmp
    "rafamadriz/friendly-snippets", -- Useful predefined snippets
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept selected item
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end,
}
