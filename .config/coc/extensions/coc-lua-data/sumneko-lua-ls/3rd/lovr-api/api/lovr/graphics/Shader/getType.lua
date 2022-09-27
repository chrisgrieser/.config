return {
  summary = 'Get the type of the Shader.',
  description = [[
    Returns the type of the Shader, which will be "graphics" or "compute".

    Graphics shaders are created with `lovr.graphics.newShader` and can be used for rendering with
    `lovr.graphics.setShader`.  Compute shaders are created with `lovr.graphics.newComputeShader`
    and can be run using `lovr.graphics.compute`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'type',
      type = 'ShaderType',
      description = 'The type of the Shader.'
    }
  },
  related = {
    'ShaderType'
  }
}
