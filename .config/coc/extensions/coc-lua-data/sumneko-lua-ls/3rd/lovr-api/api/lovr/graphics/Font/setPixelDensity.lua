return {
  summary = 'Set the pixel density of the Font.',
  description = [[
    Sets the pixel density for the Font.  Normally, this is in pixels per meter.  When rendering to
    a 2D texture, the units are pixels.
  ]],
  arguments = {
    pixelDensity = {
      type = 'number',
      description = 'The new pixel density.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'pixelDensity' },
      returns = {}
    },
    {
      description = 'Reset the pixel density to the default (`font:getRasterizer():getHeight()`).',
      arguments = {},
      returns = {}
    }
  }
}
