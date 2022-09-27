return {
  summary = 'Set the total mass of the Collider.',
  description = 'Sets the total mass of the Collider.',
  arguments = {
    {
      name = 'mass',
      type = 'number',
      description = 'The new mass for the Collider, in kilograms.'
    }
  },
  returns = {},
  related = {
    'Collider:getMassData',
    'Collider:setMassData',
    'Shape:getMass'
  }
}
