return {
  summary = 'Get a list of the triangles in the Model.',
  description = [[
    Returns 2 tables containing mesh data for the Model.

    The first table is a list of vertex positions and contains 3 numbers for the x, y, and z
    coordinate of each vertex.  The second table is a list of triangles and contains 1-based indices
    into the first table representing the first, second, and third vertices that make up each
    triangle.

    The vertex positions will be affected by node transforms.
  ]],
  arguments = {},
  returns = {
    {
      name = 'vertices',
      type = 'table',
      description = 'A flat table of numbers containing vertex positions.'
    },
    {
      name = 'indices',
      type = 'table',
      description = 'A flat table of numbers containing triangle vertex indices.'
    }
  },
  related = {
    'Model:getAABB',
    'World:newMeshCollider',
    'lovr.audio.setGeometry'
  }
}
