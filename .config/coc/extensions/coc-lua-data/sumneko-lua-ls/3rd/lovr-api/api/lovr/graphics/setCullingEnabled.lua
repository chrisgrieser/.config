return {
  tag = 'graphicsState',
  summary = 'Enable or disable backface culling.',
  description = [[
    Enables or disables culling.  Culling is an optimization that avoids rendering the back face of
    polygons.  This improves performance by reducing the number of polygons drawn, but requires that
    the vertices in triangles are specified in a consistent clockwise or counter clockwise order.
  ]],
  arguments = {
    {
      name = 'isEnabled',
      type = 'boolean',
      description = 'Whether or not culling should be enabled.'
    }
  },
  returns = {},
  notes = 'Culling is disabled by default.'
}
