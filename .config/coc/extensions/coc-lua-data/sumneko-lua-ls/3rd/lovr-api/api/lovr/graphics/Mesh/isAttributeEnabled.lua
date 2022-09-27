return {
  summary = 'Check if a vertex attribute is enabled.',
  description = [[
    Returns whether or not a vertex attribute is enabled.  Disabled attributes won't be sent to
    shaders.
  ]],
  arguments = {
    {
      name = 'attribute',
      type = 'string',
      description = 'The name of the attribute.'
    }
  },
  returns = {
    {
      name = 'enabled',
      type = 'boolean',
      description = 'Whether or not the attribute is enabled when drawing the Mesh.'
    }
  }
}
