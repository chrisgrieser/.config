return {
  summary = 'Turn a number from 0 to 1 into a point on the Curve.',
  description = [[
    Returns a point on the Curve given a parameter `t` from 0 to 1.  0 will return the first
    control point, 1 will return the last point, .5 will return a point in the "middle" of the
    Curve, etc.
  ]],
  arguments = {
    {
      name = 't',
      type = 'number',
      description = 'The parameter to evaluate the Curve at.'
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
  notes = [[
    An error will be thrown if `t` is not between 0 and 1, or if the Curve has less than two points.
  ]],
  related = {
    'Curve:getTangent',
    'Curve:render',
    'Curve:slice'
  }
}
