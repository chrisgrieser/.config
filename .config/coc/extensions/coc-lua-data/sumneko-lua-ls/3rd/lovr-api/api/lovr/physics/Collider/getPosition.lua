return {
  summary = 'Get the position of the Collider.',
  description = 'Returns the position of the Collider.',
  arguments = {},
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'The x position of the Collider, in meters.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y position of the Collider, in meters.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z position of the Collider, in meters.'
    }
  },
  related = {
    'Collider:applyForce',
    'Collider:getLinearVelocity',
    'Collider:setLinearVelocity',
    'Collider:getOrientation',
    'Collider:setOrientation',
    'Collider:getPose',
    'Collider:setPose'
  }
}
