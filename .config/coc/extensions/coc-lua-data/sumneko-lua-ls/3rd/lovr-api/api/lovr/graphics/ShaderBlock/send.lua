return {
  summary = 'Update a variable in the ShaderBlock.',
  description = 'Updates a variable in the ShaderBlock.',
  arguments = {
    variable = {
      type = 'string',
      description = 'The name of the variable to update.'
    },
    value = {
      type = '*',
      description = 'The new value of the uniform.'
    },
    blob = {
      type = 'Blob',
      description = 'A Blob to replace the block data with.'
    },
    offset = {
      type = 'number',
      default = '0',
      description = 'A byte offset into the Blob to start writing from.'
    },
    extent = {
      type = 'number',
      default = 'nil',
      description = 'The number of bytes to write.  If `nil`, writes as many bytes as possible.'
    }
  },
  returns = {
    bytes = {
      type = 'number',
      description = 'How many bytes were copied to the block.'
    }
  },
  variants = {
    {
      arguments = { 'variable', 'value' },
      returns = {}
    },
    {
      arguments = { 'blob', 'offset', 'extent' },
      returns = { 'bytes' }
    }
  },
  notes = [[
    For scalar or vector types, use tables of numbers or `vec3`s for each vector.

    For matrix types, use tables of numbers or `mat4` objects.

    `Blob`s can also be used to pass arbitrary binary data to individual variables.
  ]],
  related = {
    'Shader:send',
    'Shader:sendBlock',
    'ShaderBlock:getShaderCode',
    'ShaderBlock:getOffset',
    'ShaderBlock:getSize'
  }
}
