return {
  summary = 'Get the height of a line of text.',
  description = [[
    Returns the height of a line of text.  Units are in meters, see `Font:setPixelDensity`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'height',
      type = 'number',
      description = 'The height of a rendered line of text.'
    }
  },
  related = {
    'Rasterizer:getHeight'
  }
}
