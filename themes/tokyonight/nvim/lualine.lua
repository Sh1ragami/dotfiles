-- Normal Theme Lualine Config (Enabled with Auto theme)
return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}
      opts.options.theme = "auto"
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
