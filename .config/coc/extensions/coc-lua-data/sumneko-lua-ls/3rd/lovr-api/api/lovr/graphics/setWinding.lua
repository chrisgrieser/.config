return {
  tag = 'graphicsState',
  summary = 'Set the winding direction.',
  description = [[
    Sets the polygon winding.  The winding direction determines which face of a triangle is the
    front face and which is the back face.  This lets the graphics engine cull the back faces of
    polygons, improving performance.  The default is counterclockwise.
  ]],
  arguments = {
    {
      name = 'winding',
      type = 'Winding',
      description = 'The new winding direction.'
    }
  },
  returns = {},
  notes = [[
    Culling is initially disabled and must be enabled using `lovr.graphics.setCullingEnabled`.

    The default winding direction is counterclockwise.
  ]],
  related = {
    'lovr.graphics.setCullingEnabled',
    'lovr.graphics.isCullingEnabled'
  }
}
