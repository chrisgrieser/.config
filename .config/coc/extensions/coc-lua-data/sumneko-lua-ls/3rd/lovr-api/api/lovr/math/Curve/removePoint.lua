return {
  summary = 'Remove a control point from the Curve.',
  description = 'Removes a control point from the Curve.',
  arguments = {
    {
      name = 'index',
      type = 'number',
      description = 'The index of the control point to remove.'
    }
  },
  returns = {},
  notes = [[
    An error will be thrown if the index is less than one or more than the number of control points.
  ]],
  related = {
    'Curve:getPointCount',
    'Curve:getPoint',
    'Curve:setPoint',
    'Curve:addPoint'
  }
}
