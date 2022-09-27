return {
  summary = 'Set a control point of the Curve.',
  description = 'Changes the position of a control point on the Curve.',
  arguments = {
    {
      name = 'index',
      type = 'number',
      description = 'The index to modify.'
    },
    {
      name = 'x',
      type = 'number',
      description = 'The new x coordinate.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The new y coordinate.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The new z coordinate.'
    }
  },
  returns = {},
  notes = [[
    An error will be thrown if the index is less than one or more than the number of control points.
  ]],
  related = {
    'Curve:getPointCount',
    'Curve:getPoint',
    'Curve:addPoint',
    'Curve:removePoint'
  }
}
