return {
  summary = 'Read a variable from the ShaderBlock.',
  description = 'Returns a variable in the ShaderBlock.',
  arguments = {
    {
      name = 'name',
      type = 'string',
      description = 'The name of the variable to read.'
    }
  },
  returns = {
    {
      name = 'value',
      type = '*',
      description = 'The value of the variable.'
    }
  },
  notes = [[
    This function is really slow!  Only read back values when you need to.

    Vectors and matrices will be returned as (flat) tables.
  ]],
  related = {
    'Shader:send',
    'Shader:sendBlock',
    'ShaderBlock:getShaderCode',
    'ShaderBlock:getOffset',
    'ShaderBlock:getSize'
  }
}
