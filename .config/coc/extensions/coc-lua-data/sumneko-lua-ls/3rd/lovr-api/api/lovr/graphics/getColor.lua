return {
  tag = 'graphicsState',
  summary = 'Get the global color factor.',
  description = [[
    Returns the current global color factor.  Color components are from 0.0 to 1.0.  Every pixel
    drawn will be multiplied (i.e. tinted) by this color.
  ]],
  arguments = {},
  returns = {
    {
      name = 'r',
      type = 'number',
      description = 'The red component of the color.'
    },
    {
      name = 'g',
      type = 'number',
      description = 'The green component of the color.'
    },
    {
      name = 'b',
      type = 'number',
      description = 'The blue component of the color.'
    },
    {
      name = 'a',
      type = 'number',
      description = 'The alpha component of the color.'
    }
  },
  notes = 'The default color is `(1.0, 1.0, 1.0, 1.0)`.'
}
