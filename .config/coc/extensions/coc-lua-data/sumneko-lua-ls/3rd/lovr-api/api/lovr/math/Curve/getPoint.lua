return {
  summary = 'Get a control point of the Curve.',
  description = 'Returns a control point of the Curve.',
  arguments = {
    {
      name = 'index',
      type = 'number',
      description = 'The index to retrieve.'
    }
  },
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'The x coordinate of the control point.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y coordinate of the control point.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z coordinate of the control point.'
    }
  },
  notes = [[
    An error will be thrown if the index is less than one or more than the number of control points.
  ]],
  related = {
    'Curve:getPointCount',
    'Curve:setPoint',
    'Curve:addPoint',
    'Curve:removePoint'
  }
}
