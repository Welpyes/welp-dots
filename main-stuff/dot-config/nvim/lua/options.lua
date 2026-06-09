vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.wrap = true
vim.opt.scrolloff = 8

require('render-markdown').setup({
    render_modes = { 'n', 'c', 't' },
})

vim.opt.termguicolors = true

require('nvim-highlight-colors').setup({})

require("ibl").setup()

require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    yuck = { "yuck" },
    python = { "isort", "black" },
    rust = { "rustfmt", lsp_format = "fallback" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
  },
  formatters = {
    yuck = {
      format = function(self, bufnr, lines, callback)
        local ok, yuck_fmt = pcall(require, "yuck-fmt")
        if not ok then
          return callback("Could not load yuck-fmt module")
        end
        local sw = vim.bo[bufnr].shiftwidth
        local success, result = pcall(yuck_fmt.format, lines, sw)
        if success then
          callback(nil, result)
        else
          callback(result)
        end
      end,
    },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_format = "fallback",
  },
})
