return {
  summary = 'Send a ShaderBlock to a Shader.',
  description = [[
    Sends a ShaderBlock to a Shader.  After the block is sent, you can update the data in the block
    without needing to resend the block.  The block can be sent to multiple shaders and they will
    all see the same data from the block.
  ]],
  arguments = {
    {
      name = 'name',
      type = 'string',
      description = 'The name of the block to send to.'
    },
    {
      name = 'block',
      type = 'ShaderBlock',
      description = 'The ShaderBlock to associate with the specified block.'
    },
    {
      name = 'access',
      type = 'UniformAccess',
      default = [['readwrite']],
      description = 'How the Shader will use this block (used as an optimization hint).'
    }
  },
  returns = {},
  notes = [[
    The Shader does not need to be active to send it a block.

    Make sure the ShaderBlock's variables line up with the block variables declared in the shader
    code, otherwise you'll get garbage data in the block.  An easy way to do this is to use
    `ShaderBlock:getShaderCode` to get a GLSL snippet that is compatible with the block.
  ]],
  related = {
    'Shader:hasBlock',
    'Shader:send',
    'ShaderBlock:send',
    'ShaderBlock:getShaderCode',
    'UniformAccess',
    'ShaderBlock'
  }
}
