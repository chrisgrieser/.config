return {
  summary = 'Set the linear velocity of the Collider.',
  description = [[
    Sets the linear velocity of the Collider directly.  Usually it's preferred to use
    `Collider:applyForce` to change velocity since instantaneous velocity changes can lead to weird
    glitches.
  ]],
  arguments = {
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
  returns = {},
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
