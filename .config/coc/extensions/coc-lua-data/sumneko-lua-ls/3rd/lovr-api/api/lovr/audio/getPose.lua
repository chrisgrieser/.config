return {
  tag = 'listener',
  summary = 'Get the pose of the listener.',
  description = 'Returns the position and orientation of the virtual audio listener.',
  arguments = {},
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'The x position of the listener, in meters.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y position of the listener, in meters.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z position of the listener, in meters.'
    },
    {
      name = 'angle',
      type = 'number',
      description = 'The number of radians the listener is rotated around its axis of rotation.'
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
  related = {
    'lovr.audio.getPosition',
    'lovr.audio.getOrientation',
    'Source:getPose'
  }
}
