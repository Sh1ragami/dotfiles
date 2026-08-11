return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    opts.options = opts.options or {}
    opts.options.separator_style = "thin"
    opts.options.show_buffer_close_icons = false
    opts.options.show_close_icon = false
    opts.options.always_show_bufferline = true

    opts.highlights = {
      fill = {
        bg = "NONE",
      },
      background = {
        bg = "NONE",
      },
      tab = {
        bg = "NONE",
      },
      tab_selected = {
        bg = "NONE",
      },
      buffer_visible = {
        bg = "NONE",
      },
      buffer_selected = {
        bg = "NONE",
        bold = true,
      },
      separator = {
        bg = "NONE",
      },
      separator_selected = {
        bg = "NONE",
      },
      separator_visible = {
        bg = "NONE",
      },
    }
  end,
}
