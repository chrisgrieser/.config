return {
  summary = 'Update a specific attribute of a single vertex in the Mesh.',
  description = 'Set the components of a specific attribute of a vertex in the Mesh.',
  arguments = {
    {
      name = 'index',
      type = 'number',
      description = 'The index of the vertex to update.'
    },
    {
      name = 'attribute',
      type = 'number',
      description = 'The index of the attribute to update.'
    },
    {
      name = '...',
      type = 'number',
      description = 'The new components for the attribute.'
    }
  },
  returns = {},
  notes = [[
    Meshes without a custom format have the vertex position as their first attribute, the normal
    vector as the second attribute, and the texture coordinate as the third attribute.
  ]]
}
