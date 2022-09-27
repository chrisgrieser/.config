return {
  tag = 'graphicsState',
  summary = 'Enable or disable wireframe rendering.',
  description = [[
    Enables or disables wireframe rendering.  This is meant to be used as a debugging tool.
  ]],
  arguments = {
    {
      name = 'wireframe',
      type = 'boolean',
      description = 'Whether or not wireframe rendering should be enabled.'
    }
  },
  returns = {},
  notes = [[
    Wireframe rendering is initially disabled.

    Wireframe rendering is only supported on desktop systems.
  ]]
}
