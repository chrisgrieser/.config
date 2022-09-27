return {
  tag = 'graphicsState',
  summary = 'Get whether backface culling is enabled.',
  description = [[
    Returns whether or not culling is active.  Culling is an optimization that avoids rendering the
    back face of polygons.  This improves performance by reducing the number of polygons drawn, but
    requires that the vertices in triangles are specified in a consistent clockwise or counter
    clockwise order.
  ]],
  arguments = {},
  returns = {
    {
      name = 'isEnabled',
      type = 'boolean',
      description = 'Whether or not culling is enabled.'
    }
  },
  notes = 'Culling is disabled by default.'
}
