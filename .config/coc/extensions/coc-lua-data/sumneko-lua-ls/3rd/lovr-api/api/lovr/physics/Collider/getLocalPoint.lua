return {
  summary = 'Convert a point from world space to collider space.',
  description = [[
    Converts a point from world coordinates into local coordinates relative to the Collider.
  ]],
  arguments = {
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
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'The x position of the local-space point.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y position of the local-space point.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z position of the local-space point.'
    }
  },
  related = {
    'Collider:getWorldPoint',
    'Collider:getLocalVector',
    'Collider:getWorldVector'
  }
}
