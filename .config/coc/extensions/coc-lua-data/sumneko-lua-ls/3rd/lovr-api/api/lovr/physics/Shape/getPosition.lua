return {
  summary = 'Get the Shape\'s position.',
  description = 'Get the position of the Shape relative to its Collider.',
  arguments = {},
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'The x offset.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y offset.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z offset.'
    }
  },
  related = {
    'Shape:getOrientation',
    'Shape:setOrientation'
  }
}
