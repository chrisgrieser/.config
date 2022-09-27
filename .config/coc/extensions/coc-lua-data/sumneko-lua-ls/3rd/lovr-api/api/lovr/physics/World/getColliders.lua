return {
  tag = 'colliders',
  summary = 'Get a table of all Colliders in the World.',
  description = 'Returns a table of all Colliders in the World.',
  arguments = {
    t = {
      type = 'table',
      description = 'A table to fill with Colliders and return.'
    }
  },
  returns = {
    colliders = {
      type = 'table',
      description = 'A table of `Collider` objects.'
    }
  },
  variants = {
    {
      arguments = {},
      returns = { 'colliders' }
    },
    {
      arguments = { 't' },
      returns = { 'colliders' }
    }
  }
}
