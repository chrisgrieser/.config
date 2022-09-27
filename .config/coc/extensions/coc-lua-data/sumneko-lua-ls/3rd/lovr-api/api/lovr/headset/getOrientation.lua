return {
  tag = 'input',
  summary = 'Get the orientation of a device.',
  description = 'Returns the current orientation of a device, in angle/axis form.',
  arguments = {
    {
      name = 'device',
      type = 'Device',
      default = [['head']],
      description = 'The device to get the orientation of.'
    }
  },
  returns = {
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
  notes = ' If the device isn\'t tracked, all zeroes will be returned.',
  related = {
    'lovr.headset.getPose',
    'lovr.headset.getPosition',
    'lovr.headset.getVelocity',
    'lovr.headset.getAngularVelocity',
    'lovr.headset.isTracked',
    'lovr.headset.getDriver'
  }
}
