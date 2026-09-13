return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, c)
        hl.SnacksPickerBoxTitle = { bg = "NONE" }
        hl.SnacksPickerInputTitle = { bg = "NONE" }
        hl.SnacksPickerInputBorder = { bg = "NONE" }
        hl.SnacksPickerInput = { bg = "NONE" }
        hl.SnacksPickerBorder = { bg = "NONE" }
        hl.SnacksPickerNormal = { bg = "NONE" }
        hl.SnacksPickerNormalNC = { bg = "NONE" }
        hl.NormalFloat = { bg = "NONE" }
        hl.FloatBorder = { bg = "NONE" }
        hl.FloatTitle = { bg = "NONE" }
      end,
    },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      transparent_background = true,
      integrations = {
        snacks = true,
        transparent = true,
      },
    },
  },
}
