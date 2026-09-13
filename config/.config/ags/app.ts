import app from "ags/gtk4/app"
import style from "./style.scss"
import ControlCenter from "./widget/ControlCenter"

app.start({
  css: style,
  main() {
    app.get_monitors().map(ControlCenter)
  },
  requestHandler(argv, res) {
    const cmd = Array.isArray(argv) ? argv.join(" ") : String(argv)
    if (cmd === "toggle" || cmd === "toggle control-center") {
      const panel = app.get_window("control-center")
      if (panel) {
        panel.visible = !panel.visible
        // scrim visibility is managed by panel's notify::visible handler
      }
      res("ok")
    } else if (cmd === "close" || cmd === "close control-center") {
      const scrim = app.get_window("cc-scrim")
      const panel = app.get_window("control-center")
      if (scrim) scrim.visible = false
      if (panel) panel.visible = false
      res("ok")
    } else if (cmd === "visible") {
      const win = app.get_window("control-center")
      res(win ? String(win.visible) : "false")
    } else if (cmd.startsWith("theme ")) {
      // theme switching handled via loadTheme() on open
      res("ok")
    } else {
      res("ok")
    }
  },
})
