return {
  summary = 'Check if a Shader has a uniform variable.',
  description = 'Returns whether a Shader has a particular uniform variable.',
  arguments = {
    {
      name = 'uniform',
      type = 'string',
      description = 'The name of the uniform variable.'
    }
  },
  returns = {
    {
      name = 'present',
      type = 'boolean',
      description = 'Whether the shader has the specified uniform.'
    }
  },
  notes = [[
    If a uniform variable is defined but unused in the shader, the shader compiler will optimize it
    out and the uniform will not report itself as present.
  ]],
  related = {
    'Shader:send'
  }
}
