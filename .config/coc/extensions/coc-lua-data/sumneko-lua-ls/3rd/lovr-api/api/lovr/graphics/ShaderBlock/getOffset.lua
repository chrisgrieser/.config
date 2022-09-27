return {
  summary = 'Get the byte offset of a variable in the ShaderBlock.',
  description = [[
    Returns the byte offset of a variable in a ShaderBlock.  This is useful if you want to manually
    send binary data to the ShaderBlock using a `Blob` in `ShaderBlock:send`.
  ]],
  arguments = {
    {
      name = 'field',
      type = 'string',
      description = 'The name of the variable to get the offset of.'
    }
  },
  returns = {
    {
      name = 'offset',
      type = 'number',
      description = 'The byte offset of the variable.'
    }
  },
  related = {
    'ShaderBlock:getSize',
    'lovr.graphics.newShaderBlock'
  }
}
