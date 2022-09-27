return {
  tag = 'graphicsState',
  summary = 'Set the point size.',
  description = 'Sets the width of drawn points, in pixels.',
  arguments = {
    {
      name = 'size',
      type = 'number',
      default = '1.0',
      description = 'The new point size.'
    }
  },
  returns = {},
  related = {
    'lovr.graphics.points'
  },
  notes = 'The default point size is `1.0`.'
}
