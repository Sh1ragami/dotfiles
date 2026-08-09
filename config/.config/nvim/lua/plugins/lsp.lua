return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- pyrightの代わりに basedpyright を設定
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "basic", -- 厳しすぎる場合は "off" でもOK
                autoImportCompletions = true,
              },
            },
          },
        },
      },
    },
  },
}
