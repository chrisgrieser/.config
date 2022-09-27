return {
  summary = 'Attach attributes from another Mesh onto this one.',
  description = [[
    Attaches attributes from another Mesh onto this one.  This can be used to share vertex data
    across multiple meshes without duplicating the data, and can also be used for instanced
    rendering by using the `divisor` parameter.
  ]],
  arguments = {
    mesh = {
      type = 'Mesh',
      description = 'The Mesh to attach attributes from.'
    },
    divisor = {
      type = 'number',
      default = '0',
      description = 'The attribute divisor for all attached attributes.'
    },
    attributes = {
      type = 'table',
      description = 'A table of attribute names to attach from the other Mesh.'
    },
    ['...'] = {
      type = 'string',
      description = 'The names of attributes to attach from the other Mesh.'
    }
  },
  returns = {},
  variants = {
    {
      description = 'Attach all attributes from the other mesh.',
      arguments = { 'mesh', 'divisor' },
      returns = {}
    },
    {
      arguments = { 'mesh', 'divisor', '...' },
      returns = {}
    },
    {
      arguments = { 'mesh', 'divisor', 'attributes' },
      returns = {}
    }
  },
  notes = [[
    The attribute divisor is a  number used to control how the attribute data relates to instancing.
    If 0, then the attribute data is considered "per vertex", and each vertex will get the next
    element of the attribute's data.  If the divisor 1 or more, then the attribute data is
    considered "per instance", and every N instances will get the next element of the attribute
    data.

    To prevent cycles, it is not possible to attach attributes onto a Mesh that already has
    attributes attached to a different Mesh.
  ]],
  related = {
    'Mesh:detachAttributes',
    'Mesh:drawInstanced'
  }
}
