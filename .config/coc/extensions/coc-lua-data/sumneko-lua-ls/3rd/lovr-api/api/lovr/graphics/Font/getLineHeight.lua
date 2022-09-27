return {
  summary = 'Get the line height of the Font.',
  description = 'Returns the current line height multiplier of the Font.  The default is 1.0.',
  arguments = {},
  returns = {
    {
      name = 'lineHeight',
      type = 'number',
      description = 'The line height.'
    }
  },
  related = {
    'Font:getHeight',
    'Rasterizer:getLineHeight'
  }
}
