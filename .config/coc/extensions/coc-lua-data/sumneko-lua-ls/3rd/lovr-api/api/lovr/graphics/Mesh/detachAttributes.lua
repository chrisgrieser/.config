return {
  summary = 'Detach attributes that were attached from a different Mesh.',
  description = 'Detaches attributes that were attached using `Mesh:attachAttributes`.',
  arguments = {
    mesh = {
      type = 'Mesh',
      description = 'A Mesh.  The names of all of the attributes from this Mesh will be detached.'
    },
    attributes = {
      type = 'table',
      description = 'A table of attribute names to detach.'
    },
    ['...'] = {
      type = 'string',
      description = 'The names of attributes to detach.'
    }
  },
  returns = {},
  variants = {
    {
      description = 'Detaches all attributes from the other mesh, by name.',
      arguments = { 'mesh' },
      returns = {}
    },
    {
      arguments = { 'mesh', '...' },
      returns = {}
    },
    {
      arguments = { 'mesh', 'attributes' },
      returns = {}
    }
  },
  related = {
    'Mesh:attachAttributes'
  }
}
