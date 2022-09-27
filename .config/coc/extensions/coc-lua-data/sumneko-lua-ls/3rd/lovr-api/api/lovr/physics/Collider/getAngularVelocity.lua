return {
  summary = 'Get the angular velocity of the Collider.',
  description = 'Returns the angular velocity of the Collider.',
  arguments = {},
  returns = {
    {
      name = 'vx',
      type = 'number',
      description = 'The x component of the angular velocity.'
    },
    {
      name = 'vy',
      type = 'number',
      description = 'The y component of the angular velocity.'
    },
    {
      name = 'vz',
      type = 'number',
      description = 'The z component of the angular velocity.'
    }
  },
  related = {
    'Collider:getLinearVelocity',
    'Collider:setLinearVelocity',
    'Collider:applyTorque',
    'Collider:getOrientation',
    'Collider:setOrientation'
  }
}
