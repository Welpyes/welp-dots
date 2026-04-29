local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("i", "jj", "<ESC>")
map("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>bprev<cr>", { desc = "Prev buffer" })
map("n", "<C-n>", "<cmd>lua Snacks.explorer()<cr>", { desc = "Toggle file explorer" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>")
map("n", "<leader>b", "<cmd>enew<cr>", { desc = "New buffer" })
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>/", "gcc", { desc = "Toggle comment", remap = true })

vim.cmd('cnoreabbrev a q')
vim.cmd('cnoreabbrev aa a')
vim.cmd('cnoreabbrev ew wq')
vim.cmd('cnoreabbrev ww wq')
vim.cmd('cnoreabbrev q qa')

map("n", "<leader>lh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle LSP inlay hints" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = "snacks_picker_list",
  callback = function(args)
    vim.keymap.set("n", "<C-n>", "q", { buffer = args.buf, remap = true })
  end,
})

if os.getenv("DISPLAY") then
  vim.g.clipboard = {
    name = "x11",
    copy = {
      ["+"] = "xclip -selection clipboard",
      ["*"] = "xclip -selection primary",
    },
    paste = {
      ["+"] = "xclip -selection clipboard -o",
      ["*"] = "xclip -selection primary -o",
    },
    cache_enabled = 0,
  }
  vim.opt.clipboard = "unnamedplus"
else
  vim.opt.clipboard = "unnamed"
end
