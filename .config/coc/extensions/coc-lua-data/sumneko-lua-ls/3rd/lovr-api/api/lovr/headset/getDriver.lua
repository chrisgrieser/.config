return {
  tag = 'headset',
  summary = 'Get the VR API currently in use for a device.',
  description = [[
    Returns the `HeadsetDriver` that is currently in use, optionally for a specific device.  The
    order of headset drivers can be changed using `lovr.conf` to prefer or exclude specific VR APIs.
  ]],
  arguments = {
    device = {
      type = 'Device',
      description = [[
        The device to get the active driver of.  This will be the first driver that is currently
        returning a pose for the device.
      ]]
    }
  },
  returns = {
    driver = {
      type = 'HeadsetDriver',
      description = 'The driver of the headset in use, e.g. "OpenVR".'
    }
  },
  variants = {
    {
      description = 'Get the current headset driver that LÖVR is submitting frames to.',
      arguments = {},
      returns = { 'driver' }
    },
    {
      description = 'Get the current input driver for a device.',
      arguments = { 'device' },
      returns = { 'driver' }
    }
  }
}
