-- Catppuccin Theme Specific Lualine Config
local catppuccin_theme = {
  normal = {
    a = { bg = "#cba6f7", fg = "#11111b", bold = true },
    b = { bg = "NONE", fg = "#cba6f7" },
    c = { bg = "NONE", fg = "#a6adc8" },
  },
  insert = {
    a = { bg = "#a6e3a1", fg = "#11111b", bold = true },
    b = { bg = "NONE", fg = "#a6e3a1" },
    c = { bg = "NONE", fg = "#a6adc8" },
  },
  visual = {
    a = { bg = "#f5c2e7", fg = "#11111b", bold = true },
    b = { bg = "NONE", fg = "#f5c2e7" },
    c = { bg = "NONE", fg = "#a6adc8" },
  },
  replace = {
    a = { bg = "#f38ba8", fg = "#11111b", bold = true },
    b = { bg = "NONE", fg = "#f38ba8" },
    c = { bg = "NONE", fg = "#a6adc8" },
  },
  command = {
    a = { bg = "#89dceb", fg = "#11111b", bold = true },
    b = { bg = "NONE", fg = "#89dceb" },
    c = { bg = "NONE", fg = "#a6adc8" },
  },
  inactive = {
    a = { bg = "NONE", fg = "#6c7086", bold = true },
    b = { bg = "NONE", fg = "#6c7086" },
    c = { bg = "NONE", fg = "#6c7086" },
  },
}

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = catppuccin_theme
      opts.options.component_separators = nil
      opts.options.section_separators = nil
      vim.opt.laststatus = 3
    end,
    config = function(_, opts)
      require("lualine").setup(opts)
      vim.opt.laststatus = 3
    end,
  },
}
