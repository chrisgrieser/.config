return {
  summary = 'Apply torque to the Collider.',
  description = 'Applies torque to the Collider.',
  arguments = {
    {
      name = 'x',
      type = 'number',
      description = 'The x component of the torque.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y component of the torque.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z component of the torque.'
    }
  },
  returns = {},
  notes = [[
    If the Collider is asleep, it will need to be woken up with `Collider:setAwake` for this
    function to have any affect.
  ]],
  related = {
    'Collider:applyForce'
  }
}
