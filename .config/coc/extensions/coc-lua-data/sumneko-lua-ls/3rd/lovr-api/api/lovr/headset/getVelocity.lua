return {
  tag = 'input',
  summary = 'Get the linear velocity of a device.',
  description = 'Returns the current linear velocity of a device, in meters per second.',
  arguments = {
    {
      name = 'device',
      type = 'Device',
      default = [['head']],
      description = 'The device to get the velocity of.'
    }
  },
  returns = {
    {
      name = 'vx',
      type = 'number',
      description = 'The x component of the linear velocity.'
    },
    {
      name = 'vy',
      type = 'number',
      description = 'The y component of the linear velocity.'
    },
    {
      name = 'vz',
      type = 'number',
      description = 'The z component of the linear velocity.'
    }
  },
  related = {
    'lovr.headset.getAngularVelocity',
    'lovr.headset.getPose',
    'lovr.headset.getPosition',
    'lovr.headset.getOrientation'
  }
}
