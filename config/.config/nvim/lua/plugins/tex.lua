-- ~/.config/nvim/lua/plugins/tex.lua
return {
  {
    "lervag/vimtex",
    lazy = false, -- LaTeXファイルを開いたときに確実に読み込むため
    init = function()
      -- VimTeXのバージョンチェックを無効化 (NVIM 0.12.3でのバージョンエラーを防止)
      vim.g.vimtex_version_check = 0

      -- ビューアに Zathura を指定
      vim.g.vimtex_view_method = "zathura"

      -- コンパイルエンジン（デフォルト）を latexmk に設定
      vim.g.vimtex_compiler_method = "latexmk"

      -- コンパイル失敗(Error)時のみQuickfix/ログウィンドウを自動表示する設定
      vim.g.vimtex_quickfix_mode = 2
      vim.g.vimtex_quickfix_open_on_warning = 0

      -- 初期起動時のビューア自動起動・自動同期を無効化
      vim.g.vimtex_view_forward_search_on_start = false
      vim.g.vimtex_view_automatic = 0

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
