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

      -- 初期起動時に自動同期
      vim.g.vimtex_view_forward_search_on_start = true

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
    config = function()
      -- Neovim のカーソル位置に合わせて Zathura (PDF) 側を自動追従スクロールさせる
      -- カーソル移動後、300ms 静止したタイミングで自動同期
      vim.opt.updatetime = 300

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = vim.api.nvim_create_augroup("VimtexAutoView", { clear = true }),
        pattern = "*.tex",
        callback = function()
          if vim.b.vimtex and vim.b.vimtex.viewer then
            vim.cmd("VimtexView")
          end
        end,
      })
    end,
  },
}
