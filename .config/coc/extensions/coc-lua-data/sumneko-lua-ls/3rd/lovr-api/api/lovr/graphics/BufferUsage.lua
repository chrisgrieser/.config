return {
  summary = 'How the buffer data will be updated.',
  description = [[
    This acts as a hint to the graphics driver about what kinds of data access should be optimized for.
  ]],
  values = {
    {
      name = 'static',
      description = 'A buffer that you intend to create once and never modify.'
    },
    {
      name = 'dynamic',
      description = 'A buffer which is modified occasionally.'
    },
    {
      name = 'stream',
      description = 'A buffer which is entirely replaced on the order of every frame.'
    }
  },
  related = {
    'ShaderBlock',
    'lovr.graphics.newShaderBlock',
  }
}
