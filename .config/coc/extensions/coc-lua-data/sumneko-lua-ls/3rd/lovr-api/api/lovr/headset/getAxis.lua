return {
  tag = 'input',
  summary = 'Get the state of an analog axis on a device.',
  description = [[
    Get the current state of an analog axis on a device.  Some axes are multidimensional, for
    example a 2D touchpad or thumbstick with x/y axes.  For multidimensional axes, this function
    will return multiple values, one number for each axis.  In these cases, it can be useful to use
    the `select` function built in to Lua to select a particular axis component.
  ]],
  arguments = {
    {
      name = 'device',
      type = 'Device',
      description = 'The device.'
    },
    {
      name = 'axis',
      type = 'DeviceAxis',
      description = 'The axis.'
    }
  },
  returns = {
    {
      name = '...',
      type = 'number',
      description = [[
        The current state of the components of the axis, or `nil` if the device does not have any
        information about the axis.
      ]]
    }
  },
  notes = [[
    The axis values will be between 0 and 1 for 1D axes, and between -1 and 1 for each component of
    a multidimensional axis.
  ]],
  related = {
    'DeviceAxis',
    'lovr.headset.isDown'
  }
}
