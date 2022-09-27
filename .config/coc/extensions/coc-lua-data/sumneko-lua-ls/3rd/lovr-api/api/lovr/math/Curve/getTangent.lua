return {
  summary = 'Get the direction of the Curve at a point.',
  description = [[
    Returns a direction vector for the Curve given a parameter `t` from 0 to 1.  0 will return the
    direction at the first control point, 1 will return the direction at the last point, .5 will
    return the direction at the "middle" of the Curve, etc.
  ]],
  arguments = {
    {
      name = 't',
      type = 'number',
      description = 'Where on the Curve to compute the direction.'
    }
  },
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'The x position of the point.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y position of the point.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z position of the point.'
    }
  },
  notes = 'The direction vector returned by this function will have a length of one.',
  related = {
    'Curve:evaluate',
    'Curve:render',
    'Curve:slice'
  }
}
