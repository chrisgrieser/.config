return {
  tag = 'graphicsPrimitives',
  summary = 'Run a compute shader.',
  description = [[
    This function runs a compute shader on the GPU.  Compute shaders must be created with
    `lovr.graphics.newComputeShader` and they should implement the `void compute();` GLSL function.
    Running a compute shader doesn't actually do anything, but the Shader can modify data stored in
    `Texture`s or `ShaderBlock`s to get interesting things to happen.

    When running the compute shader, you can specify the number of times to run it in 3 dimensions,
    which is useful to iterate over large numbers of elements like pixels or array elements.
  ]],
  arguments = {
    {
      name = 'shader',
      type = 'Shader',
      description = 'The compute shader to run.'
    },
    {
      name = 'x',
      type = 'number',
      default = '1',
      description = 'The amount of times to run in the x direction.'
    },
    {
      name = 'y',
      type = 'number',
      default = '1',
      description = 'The amount of times to run in the y direction.'
    },
    {
      name = 'z',
      type = 'number',
      default = '1',
      description = 'The amount of times to run in the z direction.'
    }
  },
  returns = {},
  notes = [[
    Only compute shaders created with `lovr.graphics.newComputeShader` can be used here.

    There are GPU-specific limits on the `x`, `y`, and `z` values which can be queried in the
    `compute` entry of `lovr.graphics.getLimits`.
  ]],
  related = {
    'lovr.graphics.newComputeShader',
    'lovr.graphics.getShader',
    'lovr.graphics.setShader',
    'Shader'
  }
}
