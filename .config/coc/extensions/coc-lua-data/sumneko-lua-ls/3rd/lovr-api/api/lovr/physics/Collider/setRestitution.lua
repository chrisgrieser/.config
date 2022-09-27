return {
  summary = 'Set the bounciness of the Collider.',
  description = [[
    Sets the restitution (bounciness) of the Collider.  By default, the restitution of two Colliders
    is combined (the max is used) when they collide to cause them to bounce away from each other.
    The initial restitution is 0.
  ]],
  arguments = {
    {
      name = 'restitution',
      type = 'number',
      description = 'The new restitution.'
    }
  },
  returns = {},
  related = {
    'Collider:getFriction',
    'Collider:setFriction',
    'World:collide'
  }
}
