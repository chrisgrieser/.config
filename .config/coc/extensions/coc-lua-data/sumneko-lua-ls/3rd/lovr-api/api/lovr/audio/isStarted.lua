return {
  tag = 'devices',
  summary = 'Check if an audio device is started.',
  description = 'Returns whether an audio device is started.',
  arguments = {
    {
      name = 'type',
      type = 'AudioType',
      default = [['playback']],
      description = 'The type of device to check.'
    }
  },
  returns = {
    {
      name = 'started',
      type = 'boolean',
      description = 'Whether the device is active.'
    }
  },
  related = {
    'lovr.audio.start',
    'lovr.audio.stop'
  }
}
