return {
  summary = 'Get an attribute of a single vertex in the Mesh.',
  description = 'Returns the components of a specific attribute of a single vertex in the Mesh.',
  arguments = {
    {
      name = 'index',
      type = 'number',
      description = 'The index of the vertex to retrieve the attribute of.'
    },
    {
      name = 'attribute',
      type = 'number',
      description = 'The index of the attribute to retrieve the components of.'
    }
  },
  returns = {
    {
      name = '...',
      type = 'number',
      description = 'The components of the vertex attribute.'
    }
  },
  notes = [[
    Meshes without a custom format have the vertex position as their first attribute, the normal
    vector as the second attribute, and the texture coordinate as the third attribute.
  ]]
}
