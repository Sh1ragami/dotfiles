-- ~/.config/nvim/lua/plugins/tex.lua
return {
  {
    "lervag/vimtex",
    lazy = false, -- LaTeXファイルを開いたときに確実に読み込むため
    init = function()
      -- ビューアに Zathura を指定
      vim.g.vimtex_view_method = "zathura"

      -- コンパイルエンジン（デフォルト）を latexmk に設定
      vim.g.vimtex_compiler_method = "latexmk"

      -- コンパイル失敗(Error)時のみQuickfix/ログウィンドウを自動表示する設定
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_quickfix_open_on_warning = 0



      -- クリーンアップ時に削除する中間ファイルの拡張子を指定（数学書は中間ファイルが増えがち）
      vim.g.vimtex_compiler_clean_plugins = {
        "synctex.gz",
        "synctex.gz(busy)",
        "fdb_latexmk",
        "fls",
        "toc",
        "aux",
        "log",
        "out",
      }
    end,
  },
}
