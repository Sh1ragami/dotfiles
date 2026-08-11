return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("transparent").setup({
      extra_groups = {
        "NormalFloat",
        "FloatBorder",
        "NvimTreeNormal",
        "NvimTreeNormalNC",
        "NvimTreeWinSeparator",
        "StatusLine",
        "StatusLineNC",
        -- 📁 エクスプローラー (NeoTree / NvimTree) の黒枠・ヘッダー・背景透過
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "NeoTreeTabActive",
        "NeoTreeTabInactive",
        "NeoTreeTabLineFill",
        "NeoTreeWinSeparator",
        "NeoTreeEndOfBuffer",
        -- 📑 Bufferline / Tabline の透過
        "BufferLineFill",
        "BufferLineBackground",
        "BufferLineTab",
        "BufferLineTabSelected",
        "BufferLineTabClose",
        "BufferLineBufferSelected",
        "BufferLineBufferVisible",
        "TabLine",
        "TabLineFill",
        "TabLineSel",
      },
    })
  end,
}
