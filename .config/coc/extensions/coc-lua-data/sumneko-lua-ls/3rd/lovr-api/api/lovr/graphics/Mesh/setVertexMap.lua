return {
  summary = 'Set the vertex map of the Mesh.',
  description = [[
    Sets the vertex map.  The vertex map is a list of indices in the Mesh, allowing the reordering
    or reuse of vertices.

    Often, a vertex map is used to improve performance, since it usually requires less data to
    specify the index of a vertex than it does to specify all of the data for a vertex.
  ]],
  arguments = {
    map = {
      type = 'table',
      description = 'The new vertex map.  Each element of the table is an index of a vertex.'
    },
    blob = {
      type = 'Blob',
      description = 'A Blob to use to update vertex data.'
    },
    size = {
      type = 'number',
      default = '4',
      description = 'The size of each element of the Blob, in bytes.  Must be 2 or 4.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'map' },
      returns = {}
    },
    {
      description = 'This variant is much faster than the previous one, but is harder to use.',
      arguments = { 'blob', 'size' },
      returns = {}
    }
  }
}
