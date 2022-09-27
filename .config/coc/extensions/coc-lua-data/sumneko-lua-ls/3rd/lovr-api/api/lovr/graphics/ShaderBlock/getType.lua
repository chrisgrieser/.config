return {
  summary = 'Get the type of the ShaderBlock.',
  description = 'Returns the type of the ShaderBlock.',
  arguments = {},
  returns = {
    {
      name = 'type',
      type = 'BlockType',
      description = 'The type of the ShaderBlock.'
    }
  },
  related = {
    'ShaderBlock:getOffset',
    'lovr.graphics.newShaderBlock',
    'lovr.graphics.getLimits'
  }
}
