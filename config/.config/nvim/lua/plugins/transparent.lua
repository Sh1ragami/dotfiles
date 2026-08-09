return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  config = function()
    require("transparent").setup({
      -- 基本の透明化グループ
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal",
        "StatusLine", -- ここから下がバーの透明化に重要
        "StatusLineNC",
        "lualine_c_normal",
        "lualine_c_inactive",
        "lualine_c_insert",
        "lualine_c_visual",
        "lualine_c_replace",
        "lualine_c_command",
      },
    })
  end,
}
