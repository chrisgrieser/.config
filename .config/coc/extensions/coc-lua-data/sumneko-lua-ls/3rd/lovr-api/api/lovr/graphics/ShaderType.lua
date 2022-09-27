return {
  summary = 'Different types of shaders.',
  description = [[
    Shaders can be used for either rendering operations or generic compute tasks.  Graphics shaders
    are created with `lovr.graphics.newShader` and compute shaders are created with
    `lovr.graphics.newComputeShader`.  `Shader:getType` can be used on an existing Shader to figure
    out what type it is.
  ]],
  values = {
    {
      name = 'graphics',
      description = 'A graphics shader.'
    },
    {
      name = 'compute',
      description = 'A compute shader.'
    }
  },
  related = {
    'Shader',
    'lovr.graphics.newShader',
    'lovr.graphics.newComputeShader'
  }
}
