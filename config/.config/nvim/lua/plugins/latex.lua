return {
  -- VimTeX プラグイン & Conceal（表示モード）の設定
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_version_check = 0
      vim.g.tex_flavor = "latex"
      vim.g.tex_conceal = "abdmg"
      vim.g.vimtex_quickfix_mode = 0
    end,
  },

  -- UltiSnips スニペットエンジン (一旦無効化)
  {
    "sirver/ultisnips",
    enabled = false,
  },
}
