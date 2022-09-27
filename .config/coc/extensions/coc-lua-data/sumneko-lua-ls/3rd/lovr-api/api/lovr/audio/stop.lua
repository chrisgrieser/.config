return {
  tag = 'devices',
  summary = 'Stop an audio device.',
  description = [[
    Stops the active playback or capture device.  This may fail if:

    - The device is not started
    - No device was initialized with `lovr.audio.setDevice`
  ]],
  arguments = {
    {
      name = 'type',
      type = 'AudioType',
      default = [['playback']],
      description = 'The type of device to stop.'
    }
  },
  returns = {
    {
      name = 'stopped',
      type = 'boolean',
      description = 'Whether the device was successfully stopped.'
    }
  },
  notes = 'Switching devices with `lovr.audio.setDevice` will stop the existing one.',
  related = {
    'lovr.audio.getDevices',
    'lovr.audio.setDevice',
    'lovr.audio.start',
    'lovr.audio.isStarted'
  }
}
