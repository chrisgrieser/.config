return {
  tag = 'graphicsState',
  summary = 'Set or disable the active shader.',
  description = 'Sets or disables the Shader used for drawing.',
  arguments = {
    shader = {
      type = 'Shader',
      description = 'The shader to use.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'shader' },
      returns = {}
    },
    {
      description = 'Revert back to the default shader.',
      arguments = {},
      returns = {}
    }
  }
}
