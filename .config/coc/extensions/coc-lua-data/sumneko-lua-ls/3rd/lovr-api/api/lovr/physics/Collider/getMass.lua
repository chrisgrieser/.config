return {
  summary = 'Get the total mass of the Collider.',
  description = [[
    Returns the total mass of the Collider.  The mass of a Collider depends on its attached shapes.
  ]],
  arguments = {},
  returns = {
    {
      name = 'mass',
      type = 'number',
      description = 'The mass of the Collider, in kilograms.'
    }
  },
  related = {
    'Collider:getMassData',
    'Collider:setMassData',
    'Shape:getMass'
  }
}
