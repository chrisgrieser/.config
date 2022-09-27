return {
  summary = 'Get the size of the ShaderBlock.',
  description = 'Returns the size of the ShaderBlock\'s data, in bytes.',
  arguments = {},
  returns = {
    {
      name = 'size',
      type = 'number',
      description = 'The size of the ShaderBlock, in bytes.'
    }
  },
  related = {
    'ShaderBlock:getOffset',
    'lovr.graphics.newShaderBlock'
  }
}
