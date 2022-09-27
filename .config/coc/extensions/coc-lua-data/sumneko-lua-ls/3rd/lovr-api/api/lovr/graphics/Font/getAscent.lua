return {
  summary = 'Get the ascent of the Font.',
  description = [[
    Returns the maximum distance that any glyph will extend above the Font's baseline.  Units are
    generally in meters, see `Font:getPixelDensity`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'ascent',
      type = 'number',
      description = 'The ascent of the Font.'
    }
  },
  related = {
    'Font:getDescent',
    'Rasterizer:getAscent'
  }
}
