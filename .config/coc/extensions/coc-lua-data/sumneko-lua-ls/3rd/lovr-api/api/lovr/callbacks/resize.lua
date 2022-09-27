return {
  tag = 'callbacks',
  summary = 'Called when the window is resized.',
  description = 'This callback is called when the desktop window is resized.',
  arguments = {
    {
      name = 'width',
      type = 'number',
      description = 'The new width of the window.'
    },
    {
      name = 'height',
      type = 'number',
      description = 'The new height of the window.'
    }
  },
  returns = {},
  related = {
    'lovr.graphics.getDimensions',
    'lovr.graphics.getWidth',
    'lovr.graphics.getHeight',
    'lovr.headset.getDisplayDimensions',
    'lovr.conf'
  }
}
