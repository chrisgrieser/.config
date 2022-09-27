return {
  summary = 'Set the orientation of the Collider.',
  description = 'Sets the orientation of the Collider in angle/axis representation.',
  arguments = {
    {
      name = 'angle',
      type = 'number',
      description = 'The number of radians the Collider is rotated around its axis of rotation.'
    },
    {
      name = 'ax',
      type = 'number',
      description = 'The x component of the axis of rotation.'
    },
    {
      name = 'ay',
      type = 'number',
      description = 'The y component of the axis of rotation.'
    },
    {
      name = 'az',
      type = 'number',
      description = 'The z component of the axis of rotation.'
    }
  },
  returns = {},
  related = {
    'Collider:applyTorque',
    'Collider:getAngularVelocity',
    'Collider:setAngularVelocity',
    'Collider:getPosition',
    'Collider:setPosition',
    'Collider:getPose',
    'Collider:setPose'
  }
}
