return {
  tag = 'mathOther',
  summary = 'Create a new Curve.',
  description = 'Creates a new `Curve` from a list of control points.',
  arguments = {
    n = {
      type = 'number',
      description = 'The number of points to reserve for the Curve.'
    },
    x = {
      type = 'number',
      description = 'The x coordinate of the first control point.'
    },
    y = {
      type = 'number',
      description = 'The y coordinate of the first control point.'
    },
    z = {
      type = 'number',
      description = 'The z coordinate of the first control point.'
    },
    ['...'] = {
      type = '*',
      description = 'Additional control points.'
    },
    points = {
      type = 'table',
      description = 'A table of points, as above.'
    }
  },
  returns = {
    curve = {
      type = 'Curve',
      description = 'The new Curve.'
    }
  },
  variants = {
    {
      description = 'Create a Curve from a set of initial control points.',
      arguments = { 'x', 'y', 'z', '...' },
      returns = { 'curve' }
    },
    {
      description = 'Create a Curve from a (flat) table of points.',
      arguments = { 'points' },
      returns = { 'curve' }
    },
    {
      description = [[
        Create an empty Curve, reserving space ahead of time for a certain number of control points.
      ]],
      arguments = { 'n' },
      returns = { 'curve' }
    }
  }
}
