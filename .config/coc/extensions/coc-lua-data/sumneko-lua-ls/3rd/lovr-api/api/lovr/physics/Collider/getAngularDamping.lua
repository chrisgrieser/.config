return {
  summary = 'Get the angular damping of the Collider.',
  description = [[
    Returns the angular damping parameters of the Collider.  Angular damping makes things less
    "spinny", making them slow down their angular velocity over time.
  ]],
  arguments = {},
  returns = {
    {
      name = 'damping',
      type = 'number',
      description = 'The angular damping.'
    },
    {
      name = 'threshold',
      type = 'number',
      description = 'Velocity limit below which the damping is not applied.'
    }
  },
  notes = 'Angular damping can also be set on the World.',
  related = {
    'World:getAngularDamping',
    'World:setAngularDamping'
  }
}
