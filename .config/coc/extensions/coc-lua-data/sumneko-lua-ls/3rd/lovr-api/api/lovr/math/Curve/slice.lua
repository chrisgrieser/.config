return {
  summary = 'Get a new Curve from a slice of an existing one.',
  description = [[
    Returns a new Curve created by slicing the Curve at the specified start and end points.
  ]],
  arguments = {
    {
      name = 't1',
      type = 'number',
      description = 'The starting point to slice at.'
    },
    {
      name = 't2',
      type = 'number',
      description = 'The ending point to slice at.'
    }
  },
  returns = {
    {
      name = 'curve',
      type = 'Curve',
      description = 'A new Curve.'
    }
  },
  notes = [[
    The new Curve will have the same number of control points as the existing curve.

    An error will be thrown if t1 or t2 are not between 0 and 1, or if the Curve has less than two
    points.
  ]],
  related = {
    'Curve:evaluate',
    'Curve:render'
  }
}
