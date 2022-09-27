return {
  summary = 'Get the current vertex map of the Mesh.',
  description = [[
    Returns the current vertex map for the Mesh.  The vertex map is a list of indices in the Mesh,
    allowing the reordering or reuse of vertices.
  ]],
  arguments = {
    t = {
      type = 'table',
      description = 'The table to fill with the vertex map.'
    },
    blob = {
      type = 'Blob',
      description = [[
        The Blob to fill with the vertex map data.  It must be big enough to hold all of the
        indices.
      ]]
    }
  },
  returns = {
    map = {
      type = 'table',
      description = 'The list of indices in the vertex map, or `nil` if no vertex map is set.'
    }
  },
  variants = {
    {
      arguments = {},
      returns = { 'map' }
    },
    {
      arguments = { 't' },
      returns = { 'map' }
    },
    {
      arguments = { 'blob' },
      returns = {}
    }
  }
}
