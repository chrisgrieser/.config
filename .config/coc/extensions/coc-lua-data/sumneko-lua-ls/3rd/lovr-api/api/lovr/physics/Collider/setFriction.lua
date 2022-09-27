return {
  summary = 'Set the friction of the Collider.',
  description = [[
    Sets the friction of the Collider.  By default, the friction of two Colliders is combined
    (multiplied) when they collide to generate a friction force.  The initial friction is 0.
  ]],
  arguments = {
    {
      name = 'friction',
      type = 'number',
      description = 'The new friction.'
    }
  },
  returns = {},
  related = {
    'Collider:getRestitution',
    'Collider:setRestitution',
    'World:collide'
  }
}
