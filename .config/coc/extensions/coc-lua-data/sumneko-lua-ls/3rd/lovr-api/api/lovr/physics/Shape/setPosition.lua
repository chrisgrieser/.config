return {
  summary = 'Set the Shape\'s position.',
  description = 'Set the position of the Shape relative to its Collider.',
  arguments = {
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
  notes = 'If the Shape isn\'t attached to a Collider, this will error.',
  returns = {},
  related = {
    'Shape:getOrientation',
    'Shape:setOrientation'
  }
}
