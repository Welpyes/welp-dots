require("config.lazy")
require("config.lsp")
require("config.lualine")
require("options")
require("mappings")
require("file-maps")
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    local hl = vim.api.nvim_get_hl(0, { name = "Comment" })
    hl.italic = false
    vim.api.nvim_set_hl(0, "Comment", hl)
    vim.api.nvim_set_hl(0, "@comment", { link = "Comment" })
  end,
})
vim.cmd [[colorscheme tokyonight-night]]
