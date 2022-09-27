return {
  summary = 'VR APIs.',
  description = [[
    These are all of the supported VR APIs that LÖVR can use to power the lovr.headset module.  You
    can change the order of headset drivers using `lovr.conf` to prefer or exclude specific VR APIs.

    At startup, LÖVR searches through the list of drivers in order.  One headset driver will be used
    for rendering to the VR display, and all supported headset drivers will be used for device
    input.  The way this works is that when poses or button input is requested, the input drivers
    are queried (in the order they appear in `conf.lua`) to see if any of them currently have data
    for the specified device.  The first one that returns data will be used to provide the result.
    This allows projects to support multiple types of hardware devices.
  ]],
  values = {
    {
      name = 'desktop',
      description = 'A VR simulator using keyboard/mouse.'
    },
    {
      name = 'oculus',
      description = 'Oculus Desktop SDK.'
    },
    {
      name = 'openvr',
      description = 'OpenVR.'
    },
    {
      name = 'openxr',
      description = 'OpenXR.'
    },
    {
      name = 'vrapi',
      description = 'Oculus Mobile SDK.'
    },
    {
      name = 'pico',
      description = 'Pico.'
    },
    {
      name = 'webxr',
      description = 'WebXR.'
    }
  }
}
