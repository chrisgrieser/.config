return {
  tag = 'input',
  summary = 'Get the angular velocity of a device.',
  description = 'Returns the current angular velocity of a device.',
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
      name = 'x',
      type = 'number',
      description = 'The x component of the angular velocity.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y component of the angular velocity.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z component of the angular velocity.'
    }
  },
  related = {
    'lovr.headset.getVelocity',
    'lovr.headset.getPosition',
    'lovr.headset.getOrientation'
  }
}
