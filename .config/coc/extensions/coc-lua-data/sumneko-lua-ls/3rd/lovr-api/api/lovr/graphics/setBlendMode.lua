return {
  tag = 'graphicsState',
  summary = 'Set the blend mode.',
  description = [[
    Sets the blend mode.  The blend mode controls how each pixel's color is blended with the
    previous pixel's color when drawn.
  ]],
  arguments = {
    blend = {
      type = 'BlendMode',
      description = 'The blend mode.'
    },
    alphaBlend = {
      type = 'BlendAlphaMode',
      description = 'The alpha blend mode.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'blend', 'alphaBlend' },
      returns = {}
    },
    {
      description = 'Disable blending.',
      arguments = {},
      returns = {}
    }
  },
  notes = [[
    The default blend mode is `alpha` and `alphamultiply`.
  ]],
  related = {
    'BlendMode',
    'BlendAlphaMode'
  }
}
