return {
  tag = 'callbacks',
  summary = 'Called when a permission request is answered.',
  description = [[
    This callback contains a permission response previously requested with
    `lovr.system.requestPermission`.  The callback contains information on whether permission was
    granted or denied.
  ]],
  arguments = {
    {
      name = 'permission',
      type = 'Permission',
      description = 'The type of permission.'
    },
    {
      name = 'granted',
      type = 'boolean',
      description = 'Whether permission was granted or denied.'
    }
  },
  returns = {},
  related = {
    'lovr.system.requestPermission'
  }
}
