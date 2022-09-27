return {
  summary = 'Set the draw range of the Mesh.',
  description = [[
    Set the draw range for the Mesh.  The draw range is a subset of the vertices of the Mesh that
    will be drawn.
  ]],
  arguments = {
    start = {
      type = 'number',
      description = 'The first vertex that will be drawn.'
    },
    count = {
      type = 'number',
      description = 'The number of vertices that will be drawn.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'start', 'count' },
      returns = {}
    },
    {
      description = 'Remove the draw range, causing the Mesh to draw all of its vertices.',
      arguments = {},
      returns = {}
    }
  }
}
