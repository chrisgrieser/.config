return {
  tag = 'graphicsState',
  summary = 'Get whether wireframe mode is enabled.',
  description = 'Returns a boolean indicating whether or not wireframe rendering is enabled.',
  arguments = {},
  returns = {
    {
      name = 'isWireframe',
      type = 'boolean',
      description = 'Whether or not wireframe rendering is enabled.'
    }
  },
  notes = [[
    Wireframe rendering is initially disabled.

    Wireframe rendering is only supported on desktop systems.
  ]]
}
