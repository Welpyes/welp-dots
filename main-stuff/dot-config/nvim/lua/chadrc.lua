-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "tokyodark",

  hl_override = {
    -- Transparency: Make these groups fully transparent (bg = "NONE")
    Normal = { bg = "NONE" },
    NormalNC = { bg = "NONE" },
    NormalFloat = { bg = "NONE" },
    FloatBorder = { bg = "NONE" },
    -- StatusLine = { bg = "#d8be97" },
    StatusLineNC = { bg = "NONE" },
    TabLine = { bg = "NONE" },
    TabLineSel = { bg = "NONE" },
    WinSeparator = { bg = "NONE" },
    Visual = { bg = "#dec7b3" },
  },
}

M.nvdash = {
  load_on_startup = true,
  header = {
    "                                                  ",
    "    ▄▄▄▄                                          ",
    "  ██▀▀▀▀█                                  ██     ",
    " ██▀        ▄████▄   ████▄██▄   ▄████▄   ███████  ",
    " ██        ██▀  ▀██  ██ ██ ██  ██▄▄▄▄██    ██     ",
    " ██▄       ██    ██  ██ ██ ██  ██▀▀▀▀▀▀    ██     ",
    "  ██▄▄▄▄█  ▀██▄▄██▀  ██ ██ ██  ▀██▄▄▄▄█    ██▄▄▄  ",
    "    ▀▀▀▀     ▀▀▀▀    ▀▀ ▀▀ ▀▀    ▀▀▀▀▀      ▀▀▀▀  ",
    "                                                  ",
    "                                                  ",
  },
}

return M
