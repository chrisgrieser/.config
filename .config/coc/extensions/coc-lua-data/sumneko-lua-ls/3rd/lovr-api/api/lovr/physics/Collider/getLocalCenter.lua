return {
  summary = 'Get the Collider\'s center of mass.',
  description = 'Returns the Collider\'s center of mass.',
  arguments = {},
  returns = {
    {
      name = 'cx',
      type = 'number',
      description = 'The x position of the center of mass.'
    },
    {
      name = 'cy',
      type = 'number',
      description = 'The y position of the center of mass.'
    },
    {
      name = 'cz',
      type = 'number',
      description = 'The z position of the center of mass.'
    }
  },
  related = {
    'Collider:getLocalPoint',
    'Collider:getMassData',
    'Collider:setMassData'
  }
}
