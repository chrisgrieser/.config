return {
  tag = 'devices',
  summary = 'Start an audio device.',
  description = [[
    Starts the active playback or capture device.  By default the playback device is initialized
    and started, but this can be controlled using the `t.audio.start` flag in `lovr.conf`.
  ]],
  arguments = {
    {
      name = 'type',
      type = 'AudioType',
      default = [['playback']],
      description = 'The type of device to start.'
    }
  },
  returns = {
    {
      name = 'started',
      type = 'boolean',
      description = 'Whether the device was successfully started.'
    }
  },
  notes = [[
    Starting an audio device may fail if:

    - The device is already started
    - No device was initialized with `lovr.audio.setDevice`
    - Lack of `audiocapture` permission on Android (see `lovr.system.requestPermission`)
    - Some other problem accessing the audio device
  ]],
  related = {
    'lovr.audio.getDevices',
    'lovr.audio.setDevice',
    'lovr.audio.stop',
    'lovr.audio.isStarted',
    'lovr.system.requestPermission',
    'lovr.permission'
  }
}
