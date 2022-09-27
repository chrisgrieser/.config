return {
  summary = 'Different types of ShaderBlocks.',
  description = [[
    There are two types of ShaderBlocks that can be used: `uniform` and `compute`.

    Uniform blocks are read only in shaders, can sometimes be a bit faster than compute blocks, and
    have a limited size (but the limit will be at least 16KB, you can check
    `lovr.graphics.getLimits` to check).

    Compute blocks can be written to by compute shaders, might be slightly slower than uniform
    blocks, and have a much, much larger maximum size.
  ]],
  values = {
    {
      name = 'uniform',
      description = 'A uniform block.'
    },
    {
      name = 'compute',
      description = 'A compute block.'
    }
  },
  related = {
    'ShaderBlock',
    'lovr.graphics.newShaderBlock',
    'ShaderBlock:getType',
    'lovr.graphics.getLimits'
  }
}
