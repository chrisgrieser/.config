return {
  tag = 'input',
  summary = 'Get the pose of a device.',
  description = 'Returns the current position and orientation of a device.',
  arguments = {
    {
      name = 'device',
      type = 'Device',
      default = [['head']],
      description = 'The device to get the pose of.'
    }
  },
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'The x position.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y position.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z position.'
    },
    {
      name = 'angle',
      type = 'number',
      description = 'The amount of rotation around the axis of rotation, in radians.'
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
  notes = [[
    Units are in meters.

    If the device isn't tracked, all zeroes will be returned.
  ]],
  related = {
    'lovr.headset.getPosition',
    'lovr.headset.getOrientation',
    'lovr.headset.getVelocity',
    'lovr.headset.getAngularVelocity',
    'lovr.headset.getSkeleton',
    'lovr.headset.isTracked',
    'lovr.headset.getDriver'
  }
}
