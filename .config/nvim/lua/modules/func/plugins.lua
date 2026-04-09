local conf = require('modules.func.config')

return {
  {
    'puremourning/vimspector',
    cmd = { 'VimspectorInstall', 'VimspectorUpdate' },
    keys = {
      { '<F5>', desc = 'Vimspector' },
      { '<F9>', desc = 'Vimspector' },
    },
    config = conf.vimspector,
  },
}
