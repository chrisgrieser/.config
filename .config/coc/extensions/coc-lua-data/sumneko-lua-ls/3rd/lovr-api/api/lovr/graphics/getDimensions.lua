return {
  tag = 'window',
  summary = 'Get the dimensions of the window.',
  description = 'Returns the dimensions of the desktop window.',
  arguments = {},
  returns = {
    {
      name = 'width',
      type = 'number',
      description = 'The width of the window, in pixels.'
    },
    {
      name = 'height',
      type = 'number',
      description = 'The height of the window, in pixels.'
    }
  },
  related = {
    'lovr.graphics.getWidth',
    'lovr.graphics.getHeight',
    'lovr.graphics.getPixelDensity'
  }
}
