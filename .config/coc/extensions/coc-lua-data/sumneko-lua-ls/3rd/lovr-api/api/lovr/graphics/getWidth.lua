return {
  tag = 'window',
  summary = 'Get the width of the window.',
  description = 'Returns the width of the desktop window.',
  arguments = {},
  returns = {
    {
      name = 'width',
      type = 'number',
      description = 'The width of the window, in pixels.'
    }
  },
  related = {
    'lovr.graphics.getHeight',
    'lovr.graphics.getDimensions',
    'lovr.graphics.getPixelDensity'
  }
}
