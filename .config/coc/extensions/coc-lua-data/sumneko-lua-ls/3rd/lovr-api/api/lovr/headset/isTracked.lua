return {
  tag = 'input',
  summary = 'Check if a device is currently tracked.',
  description = [[
    Returns whether any active headset driver is currently returning pose information for a device.
  ]],
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
      name = 'tracked',
      type = 'boolean',
      description = 'Whether the device is currently tracked.'
    }
  },
  notes = [[
    If a device is tracked, it is guaranteed to return a valid pose until the next call to
    `lovr.headset.update`.
  ]]
}
