return {
  summary = 'Get the linear velocity of the Collider at a world space point.',
  description = [[
    Returns the linear velocity of a point on the Collider specified in world space.
  ]],
  arguments = {
    {
      name = 'x',
      type = 'number',
      description = 'The x coordinate in world space.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y coordinate in world space.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z coordinate in world space.'
    }
  },
  returns = {
    {
      name = 'vx',
      type = 'number',
      description = 'The x component of the velocity of the point.'
    },
    {
      name = 'vy',
      type = 'number',
      description = 'The y component of the velocity of the point.'
    },
    {
      name = 'vz',
      type = 'number',
      description = 'The z component of the velocity of the point.'
    }
  },
  related = {
    'Collider:getLinearVelocity',
    'Collider:getLinearVelocityFromLocalPoint'
  }
}
