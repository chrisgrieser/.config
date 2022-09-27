return {
  tag = 'worldProperties',
  summary = 'Set the linear damping of the World.',
  description = [[
    Sets the linear damping of the World.  Linear damping is similar to drag or air resistance,
    slowing down colliders over time as they move. Damping is only applied when linear velocity
    is over the threshold value.
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
    A linear damping of 0 means colliders won't slow down over time.  This is the default.

    Linear damping can also be set on individual colliders.
  ]],
  related = {
    'Collider:getLinearDamping',
    'Collider:setLinearDamping'
  }
}
