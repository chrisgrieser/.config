return {
  summary = 'Convert a vector from world space to local space.',
  description = [[
    Converts a direction vector from world space to local space.
  ]],
  arguments = {
    {
      name = 'wx',
      type = 'number',
      description = 'The x component of the world vector.'
    },
    {
      name = 'wy',
      type = 'number',
      description = 'The y component of the world vector.'
    },
    {
      name = 'wz',
      type = 'number',
      description = 'The z component of the world vector.'
    }
  },
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'The x coordinate of the local vector.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y coordinate of the local vector.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z coordinate of the local vector.'
    }
  },
  related = {
    'Collider:getWorldVector',
    'Collider:getLocalPoint',
    'Collider:getWorldPoint'
  }
}
