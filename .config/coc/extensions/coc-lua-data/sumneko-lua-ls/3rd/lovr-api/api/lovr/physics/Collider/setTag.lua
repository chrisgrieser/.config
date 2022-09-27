return {
  summary = 'Set the Collider\'s tag.',
  description = 'Sets the Collider\'s tag.',
  arguments = {
    {
      name = 'tag',
      type = 'string',
      description = 'The Collider\'s collision tag.'
    }
  },
  returns = {},
  notes = [[
    Collision between tags can be enabled and disabled using `World:enableCollisionBetween` and
    `World:disableCollisionBetween`.
  ]],
  related = {
    'World:disableCollisionBetween',
    'World:enableCollisionBetween',
    'World:isCollisionEnabledBetween',
    'lovr.physics.newWorld'
  }
}
