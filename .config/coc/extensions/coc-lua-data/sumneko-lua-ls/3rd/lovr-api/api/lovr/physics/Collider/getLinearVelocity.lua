return {
  summary = 'Get the linear velocity of the Collider.',
  description = [[
    Returns the linear velocity of the Collider.  This is how fast the Collider is moving.  There is
    also angular velocity, which is how fast the Collider is spinning.
  ]],
  arguments = {},
  returns = {
    {
      name = 'vx',
      type = 'number',
      description = 'The x velocity of the Collider, in meters per second.'
    },
    {
      name = 'vy',
      type = 'number',
      description = 'The y velocity of the Collider, in meters per second.'
    },
    {
      name = 'vz',
      type = 'number',
      description = 'The z velocity of the Collider, in meters per second.'
    }
  },
  related = {
    'Collider:getLinearVelocityFromLocalPoint',
    'Collider:getLinearVelocityFromWorldPoint',
    'Collider:getAngularVelocity',
    'Collider:setAngularVelocity',
    'Collider:applyForce',
    'Collider:getPosition',
    'Collider:setPosition'
  }
}
