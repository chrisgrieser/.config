return {
  tag = 'window',
  summary = 'Get the height of the window.',
  description = 'Returns the height of the desktop window.',
  arguments = {},
  returns = {
    {
      name = 'height',
      type = 'number',
      description = 'The height of the window, in pixels.'
    }
  },
  related = {
    'lovr.graphics.getWidth',
    'lovr.graphics.getDimensions',
    'lovr.graphics.getPixelDensity'
  }
}
