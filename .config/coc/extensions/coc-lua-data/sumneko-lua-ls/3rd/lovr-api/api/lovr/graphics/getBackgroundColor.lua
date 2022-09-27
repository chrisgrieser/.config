return {
  tag = 'graphicsState',
  summary = 'Get the background color.',
  description = [[
    Returns the current background color.  Color components are from 0.0 to 1.0.
  ]],
  arguments = {},
  returns = {
    {
      name = 'r',
      type = 'number',
      description = 'The red component of the background color.'
    },
    {
      name = 'g',
      type = 'number',
      description = 'The green component of the background color.'
    },
    {
      name = 'b',
      type = 'number',
      description = 'The blue component of the background color.'
    },
    {
      name = 'a',
      type = 'number',
      description = 'The alpha component of the background color.'
    }
  },
  notes = 'The default background color is `(0.0, 0.0, 0.0, 1.0)`.'
}
