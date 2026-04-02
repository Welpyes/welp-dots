require "nvchad.options"

-- add yours here!
vim.opt.scrolloff = 8

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!

require('render-markdown').setup({
    render_modes = { 'n', 'c', 't' },
})


-- Example: using the nvim-treesitter plugin setup
-- require('nvim-treesitter.configs').setup({
--     ensure_installed = { "fennel", "lua" }, -- Install the Fennel parser
--     highlight = {
--         enable = true, -- Enable highlighting
--     },
--     -- ... other treesitter settings
-- })

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.txt",
  callback = function()
    vim.bo.filetype = "markdown"
  end,
})
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = { "*.conf", "ini" },
  callback = function()
    vim.bo.filetype = "toml"
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {"lisp", "fennel", "yuck"},
  callback = function()
    -- Disable lisp indentation
    vim.bo.lisp = false
    vim.bo.lispwords = ""
    -- Use cindent for C-like behavior with parens
    vim.bo.indentexpr = ""
    vim.bo.autoindent = true
    vim.bo.cindent = true
    -- Configure cindent to treat parens like braces
    vim.bo.cinkeys = "0{,0},0),0],:,0#,!^F,o,O,e"
    vim.bo.cinoptions = "(0,u0,U0"
    -- Set 3-space indentation
    vim.bo.shiftwidth = 3
    vim.bo.tabstop = 3
    vim.bo.expandtab = true
    -- Smart Enter: splits closing bracket to new line
    vim.keymap.set("i", "<CR>", function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local after = line:sub(col + 1)
      -- Check if closing bracket is immediately after cursor (only whitespace allowed)
      local closing_match = after:match("^%s*([%)%]%}])")
      if closing_match and after:match("^%s*[%)%]%}]%s*$") then
        -- Get the closing bracket without leading whitespace
        local trimmed_after = after:match("^%s*(.-)%s*$")
        -- Delete the closing bracket from current line and add it on new line
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<End><BS><CR>   <CR>" .. trimmed_after .. "<Up><End><BS>", true, false, true), 'n', false)
        return ""
      else
        return "<CR>"
      end
    end, { buffer = true, expr = true })
  end
})
