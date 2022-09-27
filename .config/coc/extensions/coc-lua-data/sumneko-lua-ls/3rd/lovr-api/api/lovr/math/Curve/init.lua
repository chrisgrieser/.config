return {
  summary = 'A Bézier curve.',
  description = [[
    A Curve is an object that represents a Bézier curve in three dimensions.  Curves are defined by
    an arbitrary number of control points (note that the curve only passes through the first and
    last control point).

    Once a Curve is created with `lovr.math.newCurve`, you can use `Curve:evaluate` to get a point
    on the curve or `Curve:render` to get a list of all of the points on the curve.  These points
    can be passed directly to `lovr.graphics.points` or `lovr.graphics.line` to render the curve.

    Note that for longer or more complicated curves (like in a drawing application) it can be easier
    to store the path as several Curve objects.
  ]],
  constructors = {
    'lovr.math.newCurve',
    'Curve:slice'
  }
}
