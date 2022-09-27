return {
  summary = 'Get the Shape\'s orientation.',
  description = 'Get the orientation of the Shape relative to its Collider.',
  arguments = {},
  returns = {
    {
      name = 'angle',
      type = 'number',
      description = 'The number of radians the Shape is rotated.'
    },
    {
      name = 'ax',
      type = 'number',
      description = 'The x component of the rotation axis.'
    },
    {
      name = 'ay',
      type = 'number',
      description = 'The y component of the rotation axis.'
    },
    {
      name = 'az',
      type = 'number',
      description = 'The z component of the rotation axis.'
    }
  },
  related = {
    'Shape:getPosition',
    'Shape:setPosition'
  }
}
