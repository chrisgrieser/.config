return {
  tag = 'input',
  summary = 'Check if a button on a device is touched.',
  description = 'Returns whether a button on a device is currently touched.',
  arguments = {
    {
      name = 'device',
      type = 'Device',
      description = 'The device.'
    },
    {
      name = 'button',
      type = 'DeviceButton',
      description = 'The button.'
    }
  },
  returns = {
    {
      name = 'touched',
      type = 'boolean',
      description = [[
        Whether the button on the device is currently touched, or `nil` if the device does not have
        the button or it isn't touch-sensitive.
      ]]
    }
  },
  related = {
    'DeviceButton',
    'lovr.headset.isDown',
    'lovr.headset.getAxis'
  }
}
