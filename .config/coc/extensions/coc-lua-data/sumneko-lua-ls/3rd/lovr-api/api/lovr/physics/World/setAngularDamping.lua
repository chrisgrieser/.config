return {
  tag = 'worldProperties',
  summary = 'Set the angular damping of the World.',
  description = [[
    Sets the angular damping of the World.  Angular damping makes things less "spinny", making them
    slow down their angular velocity over time. Damping is only applied when angular velocity
    is over the threshold value.
  ]],
  arguments = {
    {
      name = 'damping',
      type = 'number',
      description = 'The angular damping.'
    },
    {
      name = 'threshold',
      type = 'number',
      default = '0',
      description = 'Velocity limit below which the damping is not applied.'
    }
  },
  returns = {},
  notes = 'Angular damping can also be set on individual colliders.',
  related = {
    'Collider:getAngularDamping',
    'Collider:setAngularDamping'
  }
}
