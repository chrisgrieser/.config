return {
  tag = 'sourceEffects',
  summary = 'Set the pose of the Source.',
  description = 'Sets the position and orientation of the Source.',
  arguments = {
    {
      name = 'x',
      type = 'number',
      description = 'The x position of the Source, in meters.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y position of the Source, in meters.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z position of the Source, in meters.'
    },
    {
      name = 'angle',
      type = 'number',
      description = 'The number of radians the Source is rotated around its axis of rotation.'
    },
    {
      name = 'ax',
      type = 'number',
      description = 'The x component of the axis of rotation.'
    },
    {
      name = 'ay',
      type = 'number',
      description = 'The y component of the axis of rotation.'
    },
    {
      name = 'az',
      type = 'number',
      description = 'The z component of the axis of rotation.'
    }
  },
  returns = {},
  related = {
    'Source:setPosition',
    'Source:setOrientation',
    'lovr.audio.setPose'
  }
}
