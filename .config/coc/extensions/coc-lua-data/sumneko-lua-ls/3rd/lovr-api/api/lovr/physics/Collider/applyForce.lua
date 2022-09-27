return {
  summary = 'Apply a force to the Collider.',
  description = 'Applies a force to the Collider.',
  arguments = {
    x = {
      type = 'number',
      description = 'The x component of the force to apply.'
    },
    y = {
      type = 'number',
      description = 'The y component of the force to apply.'
    },
    z = {
      type = 'number',
      description = 'The z component of the force to apply.'
    },
    px = {
      type = 'number',
      description = 'The x position to apply the force at, in world coordinates.'
    },
    py = {
      type = 'number',
      description = 'The y position to apply the force at, in world coordinates.'
    },
    pz = {
      type = 'number',
      description = 'The z position to apply the force at, in world coordinates.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'x', 'y', 'z' },
      returns = {}
    },
    {
      arguments = { 'x', 'y', 'z', 'px', 'py', 'pz' },
      returns = {}
    }
  },
  notes = [[
    If the Collider is asleep, it will need to be woken up with `Collider:setAwake` for this
    function to have any affect.
  ]],
  related = {
    'Collider:applyTorque'
  }
}
