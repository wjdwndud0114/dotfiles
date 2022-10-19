local func = {}
local conf = require('modules.func.config')

func['puremourning/vimspector'] = {
  cmd = { "VimspectorInstall", "VimspectorUpdate" },
  fn = { "vimspector#Launch()", "vimspector#ToggleBreakpoint", "vimspector#Continue" },
  config = conf.vimspector,
}

return func
