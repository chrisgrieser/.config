return {
  tag = 'graphicsState',
  summary = 'Get the line width.',
  description = 'Returns the current line width.',
  arguments = {},
  returns = {
    {
      name = 'width',
      type = 'number',
      description = 'The current line width, in pixels.'
    }
  },
  related = {
    'lovr.graphics.line'
  },
  notes = 'The default line width is `1`.'
}
