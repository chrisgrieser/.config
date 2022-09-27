return {
  summary = 'Different ways Mesh objects can be drawn.',
  description = [[
    Meshes are lists of arbitrary vertices.  These vertices can be connected in different ways,
    leading to different shapes like lines and triangles.
  ]],
  values = {
    {
      name = 'points',
      description = 'Draw each vertex as a single point.'
    },
    {
      name = 'lines',
      description = [[
        The vertices represent a list of line segments. Each pair of vertices will have a line drawn
        between them.
      ]]
    },
    {
      name = 'linestrip',
      description = [[
        The first two vertices have a line drawn between them, and each vertex after that will be
        connected to the previous vertex with a line.
      ]]
    },
    {
      name = 'lineloop',
      description = 'Similar to linestrip, except the last vertex is connected back to the first.'
    },
    {
      name = 'strip',
      description = [[
        The first three vertices define a triangle.  Each vertex after that creates a triangle using
        the new vertex and last two vertices.
      ]]
    },
    {
      name = 'triangles',
      description = 'Each set of three vertices represents a discrete triangle.'
    },
    {
      name = 'fan',
      description = [[
        Draws a set of triangles.  Each one shares the first vertex as a common point, leading to a
        fan-like shape.
      ]]
    }
  }
}
