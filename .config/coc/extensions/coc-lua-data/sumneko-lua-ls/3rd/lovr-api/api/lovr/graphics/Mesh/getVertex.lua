return {
  summary = 'Get a single vertex in the Mesh.',
  description = [[
    Gets the data for a single vertex in the Mesh.  The set of data returned depends on the Mesh's
    vertex format.  The default vertex format consists of 8 floating point numbers: the vertex
    position, the vertex normal, and the texture coordinates.
  ]],
  arguments = {
    {
      name = 'index',
      type = 'number',
      description = 'The index of the vertex to retrieve.'
    }
  },
  returns = {
    {
      name = '...',
      type = 'number',
      description = 'All attributes of the vertex.'
    }
  }
}
