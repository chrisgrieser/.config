return {
  summary = 'Get the number of vertices the Mesh can hold.',
  description = 'Returns the maximum number of vertices the Mesh can hold.',
  arguments = {},
  returns = {
    {
      name = 'size',
      type = 'number',
      description = 'The number of vertices the Mesh can hold.'
    }
  },
  notes = [[
    The size can only be set when creating the Mesh, and cannot be changed afterwards.

    A subset of the Mesh's vertices can be rendered, see `Mesh:setDrawRange`.
  ]]
}
