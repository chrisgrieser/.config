return {
  summary = 'Get the friction of the Collider.',
  description = [[
    Returns the friction of the Collider.  By default, the friction of two Colliders is combined
    (multiplied) when they collide to generate a friction force.  The initial friction is 0.
  ]],
  arguments = {},
  returns = {
    {
      name = 'friction',
      type = 'number',
      description = 'The friction of the Collider.'
    }
  },
  related = {
    'Collider:getRestitution',
    'Collider:setRestitution',
    'World:collide'
  }
}
