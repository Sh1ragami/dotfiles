return {
  "xiyaowong/transparent.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    local transparent = require("transparent")
    transparent.setup({
      extra_groups = {
        "NormalFloat",
        "FloatBorder",
        "FloatTitle",
        "FloatFooter",
        "NvimTreeNormal",
        "NvimTreeNormalNC",
        "NvimTreeWinSeparator",
        "StatusLine",
        "StatusLineNC",
        -- 📁 NeoTree
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "NeoTreeTabActive",
        "NeoTreeTabInactive",
        "NeoTreeTabLineFill",
        "NeoTreeWinSeparator",
        "NeoTreeEndOfBuffer",
        -- 🍿 Snacks (Explorer / Picker / Dashboard / Win / Input)
        "SnacksPicker",
        "SnacksPickerBorder",
        "SnacksPickerTitle",
        "SnacksPickerBoxTitle",
        "SnacksPickerInput",
        "SnacksPickerInputTitle",
        "SnacksPickerInputBorder",
        "SnacksPickerInputSearch",
        "SnacksPickerNormal",
        "SnacksPickerNormalNC",
        "SnacksPickerList",
        "SnacksPickerListBorder",
        "SnacksPickerListTitle",
        "SnacksPickerPreview",
        "SnacksPickerPreviewBorder",
        "SnacksPickerPreviewTitle",
        "SnacksPickerTree",
        "SnacksPickerWin",
        "SnacksPickerWinBar",
        "SnacksPickerBox",
        "SnacksPickerBoxNC",
        "SnacksPickerBoxBorder",
        "SnacksPickerInputNC",
        "SnacksPickerInputFooter",
        "SnacksPickerFooter",
        "SnacksPickerSearch",
        "SnacksPickerMatch",
        "SnacksPickerPrompt",
        "SnacksPickerToggle",
        "SnacksPickerPickWin",
        "SnacksPickerPickWinCurrent",
        "SnacksNormal",
        "SnacksNormalNC",
        "SnacksWinBar",
        "SnacksWinBarNC",
        "SnacksBackdrop",
        "SnacksInputTitle",
        "SnacksInputBorder",
        "SnacksInputIcon",
        "SnacksDashboardHeader",
        "SnacksDashboardTitle",
        "SnacksDashboardIcon",
        "SnacksDashboardKey",
        "SnacksDashboardDesc",
        "SnacksDashboardFooter",
        "SnacksDashboardSpecial",
        "SnacksDashboardDir",
        -- 📑 Bufferline / Tabline
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

    -- SnacksのPicker/Explorerが動的にハイライトを生成した際にも背景を強制消去するフック
    local function clear_snacks_bg()
      local hls = vim.api.nvim_get_hl(0, {})
      for name, hl in pairs(hls) do
        if (name:find("^Snacks") or name:find("Picker")) and name ~= "SnacksBackdrop" and hl.bg then
          local new_hl = vim.tbl_extend("force", hl, { bg = "NONE", ctermbg = "NONE" })
          vim.api.nvim_set_hl(0, name, new_hl)
        end
      end
    end

    vim.api.nvim_create_autocmd({ "ColorScheme", "BufWinEnter", "FileType" }, {
      group = vim.api.nvim_create_augroup("TransparentSnacksFix", { clear = true }),
      pattern = "*",
      callback = clear_snacks_bg,
    })

    transparent.clear()
  end,
}
