return {
  summary = 'Convert a vector from local space to world space.',
  description = [[
    Converts a direction vector from local space to world space.
  ]],
  arguments = {
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
  returns = {
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
  related = {
    'Collider:getLocalVector',
    'Collider:getLocalPoint',
    'Collider:getWorldPoint'
  }
}
