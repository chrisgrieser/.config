return {
  summary = 'Get the Collider\'s tag.',
  description = 'Returns the Collider\'s tag.',
  arguments = {},
  returns = {
    {
      name = 'tag',
      type = 'string',
      description = 'The Collider\'s collision tag.'
    }
  },
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
