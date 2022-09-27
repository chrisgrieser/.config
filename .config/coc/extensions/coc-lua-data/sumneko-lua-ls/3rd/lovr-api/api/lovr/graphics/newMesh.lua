return {
  tag = 'graphicsObjects',
  summary = 'Create a new Mesh.',
  description = [[
    Creates a new Mesh.  Meshes contain the data for an arbitrary set of vertices, and can be drawn.
    You must specify either the capacity for the Mesh or an initial set of vertex data.  Optionally,
    a custom format table can be used to specify the set of vertex attributes the mesh will provide
    to the active shader.  The draw mode and usage hint can also optionally be specified.

    The default data type for an attribute is `float`, and the default component count is 1.
  ]],
  arguments = {
    size = {
      type = 'number',
      description = 'The maximum number of vertices the Mesh can store.'
    },
    mode = {
      type = 'DrawMode',
      default = [['fan']],
      description = 'How the Mesh will connect its vertices into triangles.'
    },
    usage = {
      type = 'MeshUsage',
      default = [['dynamic']],
      description = [[
        An optimization hint indicating how often the data in the Mesh will be updated.
      ]]
    },
    readable = {
      type = 'boolean',
      default = 'false',
      description = 'Whether vertices from the Mesh can be read.'
    },
    vertices = {
      type = 'table',
      description = 'A table of vertices.  Each vertex is a table containing the vertex data.'
    },
    blob = {
      type = 'Blob',
      description = 'A binary Blob containing vertex data.'
    },
    format = {
      type = 'table',
      description = 'A table describing the attribute format for the vertices.'
    }
  },
  returns = {
    mesh = {
      type = 'Mesh',
      description = 'The new Mesh.'
    }
  },
  variants = {
    {
      arguments = { 'size', 'mode', 'usage', 'readable' },
      returns = { 'mesh' }
    },
    {
      arguments = { 'vertices', 'mode', 'usage', 'readable' },
      returns = { 'mesh' }
    },
    {
      arguments = { 'blob', 'mode', 'usage', 'readable' },
      returns = { 'mesh' }
    },
    {
      description = [[
        These variants accept a custom vertex format.  For more info, see the `Mesh` page.
      ]],
      arguments = { 'format', 'size', 'mode', 'usage', 'readable' },
      returns = { 'mesh' }
    },
    {
      arguments = { 'format', 'vertices', 'mode', 'usage', 'readable' },
      returns = { 'mesh' }
    },
    {
      arguments = { 'format', 'blob', 'mode', 'usage', 'readable' },
      returns = { 'mesh' }
    }
  },
  notes = [[
    Once created, the size and format of the Mesh cannot be changed.'

    The default mesh format is:

        {
          { 'lovrPosition',    'float', 3 },
          { 'lovrNormal',      'float', 3 },
          { 'lovrTexCoord',    'float', 2 }
        }
  ]]
}
