-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "kintsukuroi", 

  hl_override = {
    -- Italics for comments (your original)
    Comment = { italic = true },
    ["@comment"] = { italic = false },

    -- Transparency: Make these groups fully transparent (bg = "NONE")
    Normal = { bg = "NONE" },
    NormalNC = { bg = "NONE" },
    NormalFloat = { bg = "NONE" },
    FloatBorder = { bg = "NONE" },
    StatusLine = { bg = "#d8be97" },
    StatusLineNC = { bg = "NONE" },
    TabLine = { bg = "NONE" },
    TabLineSel = { bg = "NONE" },
    WinSeparator = { bg = "NONE" },
    -- Add more if needed, e.g., for Telescope: TelescopeBorder = { bg = "NONE" }

    -- Custom changes: Tweak colors/styles to "variant-ize" Rose Pine
    -- Example 1: Softer "moon" vibe (muted blues/greens, lower contrast)
    -- Comment = { fg = "#9ccfd8", italic = true },  -- Softer cyan
    -- String = { fg = "#b4f9f8" },  -- Lighter teal
    -- ["@variable"] = { fg = "#c7d2fe" },  -- Paler lavender

    -- Example 2: Higher contrast "main" punch (vibrant pinks/roses)
    -- Function = { fg = "#ebbcba", bold = true },  -- Brighter rose
    -- Keyword = { fg = "#f4b8e4", italic = true },  -- Vivid pink

    -- Example 3: Light "dawn" shift (warm neutrals—uncomment to test)
    -- Normal = { fg = "#908caa", bg = "NONE" },  -- Muted purple fg
    -- CursorLine = { bg = "#f2e9e1" },  -- Subtle warm bg (non-transparent if desired)

    -- Git signs (e.g., make adds greener)
    -- GitSignsAdd = { fg = "#a6e3a1" },
    -- GitSignsChange = { fg = "#f9e2af" },
    -- GitSignsDelete = { fg = "#f28fad" },
    --
    -- -- LSP diagnostics (e.g., error in brighter red)
    -- DiagnosticError = { fg = "#f38ba8", bold = true },
    -- DiagnosticWarn = { fg = "#fab387" },
    -- DiagnosticInfo = { fg = "#89b4fa" },
    -- DiagnosticHint = { fg = "#a6e3a1" },
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
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }


return M
