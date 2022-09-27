return {
  summary = 'Convert a point from local space to world space.',
  description = 'Convert a point relative to the collider to a point in world coordinates.',
  arguments = {
    {
      name = 'x',
      type = 'number',
      description = 'The x position of the point.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y position of the point.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z position of the point.'
    }
  },
  returns = {
    {
      name = 'wx',
      type = 'number',
      description = 'The x coordinate of the world point.'
    },
    {
      name = 'wy',
      type = 'number',
      description = 'The y coordinate of the world point.'
    },
    {
      name = 'wz',
      type = 'number',
      description = 'The z coordinate of the world point.'
    }
  },
  related = {
    'Collider:getLocalPoint',
    'Collider:getLocalVector',
    'Collider:getWorldVector'
  }
}
