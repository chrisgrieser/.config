return {
  summary = 'Check if a Shader has a block.',
  description = [[
    Returns whether a Shader has a block.

    A block is added to the Shader code at creation time using `ShaderBlock:getShaderCode`.  The
    block name (not the namespace) is used to link up the ShaderBlock object to the Shader.  This
    function can be used to check if a Shader was created with a block using the given name.
  ]],
  arguments = {
    {
      name = 'block',
      type = 'string',
      description = 'The name of the block.'
    }
  },
  returns = {
    {
      name = 'present',
      type = 'boolean',
      description = 'Whether the shader has the specified block.'
    }
  },
  related = {
    'Shader:sendBlock'
  }
}
