-- Sunset Theme Specific Lualine Config
local sunset_theme = {
  normal = {
    a = { bg = "#ea6962", fg = "#1d2021", bold = true },
    b = { bg = "NONE", fg = "#ea6962" },
    c = { bg = "NONE", fg = "#ebdbb2" },
  },
  insert = {
    a = { bg = "#e5c07b", fg = "#1d2021", bold = true },
    b = { bg = "NONE", fg = "#e5c07b" },
    c = { bg = "NONE", fg = "#ebdbb2" },
  },
  visual = {
    a = { bg = "#d3869b", fg = "#1d2021", bold = true },
    b = { bg = "NONE", fg = "#d3869b" },
    c = { bg = "NONE", fg = "#ebdbb2" },
  },
  replace = {
    a = { bg = "#e67e80", fg = "#1d2021", bold = true },
    b = { bg = "NONE", fg = "#e67e80" },
    c = { bg = "NONE", fg = "#ebdbb2" },
  },
  command = {
    a = { bg = "#89b482", fg = "#1d2021", bold = true },
    b = { bg = "NONE", fg = "#89b482" },
    c = { bg = "NONE", fg = "#ebdbb2" },
  },
  inactive = {
    a = { bg = "NONE", fg = "#928374", bold = true },
    b = { bg = "NONE", fg = "#928374" },
    c = { bg = "NONE", fg = "#928374" },
  },
}

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = sunset_theme
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
