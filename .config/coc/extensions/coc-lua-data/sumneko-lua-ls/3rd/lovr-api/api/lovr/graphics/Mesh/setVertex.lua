return {
  summary = 'Update a single vertex in the Mesh.',
  description = 'Update a single vertex in the Mesh.',
  arguments = {
    {
      name = 'index',
      type = 'number',
      description = 'The index of the vertex to set.'
    },
    {
      name = '...',
      type = 'number',
      description = 'The attributes of the vertex.'
    }
  },
  returns = {},
  notes = 'Any unspecified components will be set to 0.',
  example = {
    description = 'Set the position of a vertex:',
    code = [[
      function lovr.load()
        mesh = lovr.graphics.newMesh({
          { -1, 1, 0,  0, 0, 1,  0, 0 },
          { 1, 1, 0,  0, 0, 1,  1, 0 },
          { -1, -1, 0,  0, 0, 1,  0, 1 },
          { 1, -1, 0,  0, 0, 1,  1, 1 }
        }, 'strip')

        mesh:setVertex(2, { 7, 7, 7 })
        print(mesh:getVertex(2)) -- 7, 7, 7, 0, 0, 0, 0, 0
      end
    ]]
  }
}
