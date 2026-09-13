-- TokyoNight Theme Specific Lualine Config
local tokyonight_theme = {
  normal = {
    a = { bg = "#7aa2f7", fg = "#1a1b26", bold = true },
    b = { bg = "NONE", fg = "#7aa2f7" },
    c = { bg = "NONE", fg = "#a9b1d6" },
  },
  insert = {
    a = { bg = "#9ece6a", fg = "#1a1b26", bold = true },
    b = { bg = "NONE", fg = "#9ece6a" },
    c = { bg = "NONE", fg = "#a9b1d6" },
  },
  visual = {
    a = { bg = "#bb9af7", fg = "#1a1b26", bold = true },
    b = { bg = "NONE", fg = "#bb9af7" },
    c = { bg = "NONE", fg = "#a9b1d6" },
  },
  replace = {
    a = { bg = "#f7768e", fg = "#1a1b26", bold = true },
    b = { bg = "NONE", fg = "#f7768e" },
    c = { bg = "NONE", fg = "#a9b1d6" },
  },
  command = {
    a = { bg = "#7dcfff", fg = "#1a1b26", bold = true },
    b = { bg = "NONE", fg = "#7dcfff" },
    c = { bg = "NONE", fg = "#a9b1d6" },
  },
  inactive = {
    a = { bg = "NONE", fg = "#565f89", bold = true },
    b = { bg = "NONE", fg = "#565f89" },
    c = { bg = "NONE", fg = "#565f89" },
  },
}

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = tokyonight_theme
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
