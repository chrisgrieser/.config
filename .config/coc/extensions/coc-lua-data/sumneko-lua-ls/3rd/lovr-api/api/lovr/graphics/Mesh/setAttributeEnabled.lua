return {
  summary = 'Enable or disable a vertex attribute.',
  description = [[
    Sets whether a vertex attribute is enabled.  Disabled attributes won't be sent to shaders.
  ]],
  arguments = {
    {
      name = 'attribute',
      type = 'string',
      description = 'The name of the attribute.'
    },
    {
      name = 'enabled',
      type = 'boolean',
      description = 'Whether or not the attribute is enabled when drawing the Mesh.'
    }
  },
  returns = {}
}
