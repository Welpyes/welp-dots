require("nvchad.configs.lspconfig").defaults()

local servers = {
  -- "html",
  "cssls",
  "bashls",
  "luals",
  "pyrefly",
  "clangd",
  "gopls",
  "kotlin_language_server",
  -- "rust_analyzer"
}
vim.lsp.enable(servers)

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)  -- Show docs
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)  -- Go to definition
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)  -- Show references
  end,
})


vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      workspace = {
        library = {
          ["/data/data/com.termux/files/home/.config/awesome/.lua"] = true
        }
      }
    }
  }
})
