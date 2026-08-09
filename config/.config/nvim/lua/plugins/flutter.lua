return {
  -- Dartのシンタックスハイライトを追加
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "dart" })
      end
    end,
  },

  -- Flutter開発用スーパーツール (LSPのセットアップも兼ねる)
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- UIを綺麗にするため（LazyVimには元々入っています）
    },
    config = function()
      -- LazyVimの補完機能(blink.cmpやnvim-cmp)にLSPを繋ぎ込むための設定
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      if pcall(require, "cmp_nvim_lsp") then
        capabilities = require("cmp_nvim_lsp").default_capabilities()
      end

      require("flutter-tools").setup({
        ui = {
          border = "rounded",
        },
        decorations = {
          statusline = {
            app_version = true,
            device = true,
          },
        },
        lsp = {
          capabilities = capabilities,
          color = { -- エディタ内に色(Color)のプレビューを表示する
            enabled = true,
            background = false,
            virtual_text = true,
            virtual_text_str = "■",
          },
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            renameFilesWithClasses = "prompt", -- クラス名変更時にファイル名も変更するか聞く
            enableSnippets = true,
            updateImportsOnRename = true,
          },
        },
      })
    end,
  },
}
