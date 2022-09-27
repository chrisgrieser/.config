return {
  summary = 'Update multiple vertices in the Mesh.',
  description = 'Updates multiple vertices in the Mesh.',
  arguments = {
    vertices = {
      type = 'table',
      description = 'The new set of vertices.'
    },
    blob = {
      type = 'Blob',
      description = 'A Blob containing binary vertex data to upload (this is much more efficient).'
    },
    start = {
      type = 'number',
      default = '1',
      description = 'The index of the vertex to start replacing at.'
    },
    count = {
      type = 'number',
      default = 'nil',
      description = 'The number of vertices to replace.  If nil, all vertices will be used.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'vertices', 'start', 'count' },
      returns = {}
    },
    {
      arguments = { 'blob', 'start', 'count' },
      returns = {}
    }
  },
  notes = [[
    The start index plus the number of vertices in the table should not exceed the maximum size of
    the Mesh.
  ]]
}
