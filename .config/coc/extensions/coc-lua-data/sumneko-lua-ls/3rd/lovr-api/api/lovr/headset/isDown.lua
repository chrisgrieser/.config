return {
  tag = 'input',
  summary = 'Get the state of a button on a device.',
  description = 'Returns whether a button on a device is pressed.',
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
      name = 'down',
      type = 'boolean',
      description = [[
        Whether the button on the device is currently pressed, or `nil` if the device does not have
        the specified button.
      ]]
    }
  },
  related = {
    'DeviceButton',
    'lovr.headset.wasPressed',
    'lovr.headset.wasReleased',
    'lovr.headset.isTouched',
    'lovr.headset.getAxis'
  }
}
