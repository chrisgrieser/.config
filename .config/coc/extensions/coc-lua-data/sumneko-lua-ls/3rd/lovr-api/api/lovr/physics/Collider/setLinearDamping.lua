return {
  summary = 'Set the linear damping of the Collider.',
  description = [[
    Sets the Collider's linear damping parameter.  Linear damping is similar to drag or air
    resistance, slowing the Collider down over time. Damping is only applied when linear
    velocity is over the threshold value.
  ]],
  arguments = {
    {
      name = 'damping',
      type = 'number',
      description = 'The linear damping.'
    },
    {
      name = 'threshold',
      type = 'number',
      default = '0',
      description = 'Velocity limit below which the damping is not applied.'
    }
  },
  returns = {},
  notes = [[
    A linear damping of 0 means the Collider won't slow down over time.  This is the default.

    Linear damping can also be set on the World using `World:setLinearDamping`, which will affect
    all new colliders.
  ]],
  related = {
    'World:getLinearDamping',
    'World:setLinearDamping'
  }
}
