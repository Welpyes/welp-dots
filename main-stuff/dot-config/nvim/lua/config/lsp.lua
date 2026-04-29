vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

local servers = {
  -- "html",
  "cssls",
  "bashls",
  "lua_ls",
  "pyrefly",
  "clangd",
  "gopls",
  "kotlin_language_server",
  -- "rust_analyzer"
}

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)  -- Show docs
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)  -- Go to definition
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)  -- Show references
  end,
})


vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
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

vim.lsp.enable(servers)
