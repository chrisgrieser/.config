return {
  summary = 'Get the linear velocity of the Collider at a point.',
  description = [[
    Returns the linear velocity of a point relative to the Collider.
  ]],
  arguments = {
    {
      name = 'x',
      type = 'number',
      description = 'The x coordinate.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y coordinate.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z coordinate.'
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
    'Collider:getLinearVelocityFromWorldPoint'
  }
}
