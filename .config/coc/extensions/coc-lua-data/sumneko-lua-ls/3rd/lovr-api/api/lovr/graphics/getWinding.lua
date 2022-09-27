return {
  tag = 'graphicsState',
  summary = 'Get the winding direction.',
  description = [[
    Returns the current polygon winding.  The winding direction determines which face of a triangle
    is the front face and which is the back face.  This lets the graphics engine cull the back faces
    of polygons, improving performance.
  ]],
  arguments = {},
  returns = {
    {
      name = 'winding',
      type = 'Winding',
      description = 'The current winding direction.'
    }
  },
  notes = [[
    Culling is initially disabled and must be enabled using `lovr.graphics.setCullingEnabled`.

    The default winding direction is counterclockwise.
  ]],
  related = {
    'lovr.graphics.setCullingEnabled',
    'lovr.graphics.isCullingEnabled'
  }
}
