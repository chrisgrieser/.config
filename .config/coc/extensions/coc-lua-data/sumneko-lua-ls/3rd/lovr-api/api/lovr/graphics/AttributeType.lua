return {
  summary = 'Different data types for the vertex attributes of a Mesh.',
  description = [[
    Here are the different data types available for vertex attributes in a Mesh.  The ones that have
    a smaller range take up less memory, which improves performance a bit.  The "u" stands for
    "unsigned", which means it can't hold negative values but instead has a larger positive range.
  ]],
  values = {
    {
      name = 'byte',
      description = 'A signed 8 bit number, from -128 to 127.'
    },
    {
      name = 'ubyte',
      description = 'An unsigned 8 bit number, from 0 to 255.'
    },
    {
      name = 'short',
      description = 'A signed 16 bit number, from -32768 to 32767.'
    },
    {
      name = 'ushort',
      description = 'An unsigned 16 bit number, from 0 to 65535.'
    },
    {
      name = 'int',
      description = 'A signed 32 bit number, from -2147483648 to 2147483647.'
    },
    {
      name = 'uint',
      description = 'An unsigned 32 bit number, from 0 to 4294967295.'
    },
    {
      name = 'float',
      description = 'A 32 bit floating-point number (large range, but can start to lose precision).'
    }
  },
  related = {
    'lovr.graphics.newMesh',
    'Mesh:getVertexFormat',
    'Mesh'
  }
}
