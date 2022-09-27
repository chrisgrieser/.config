return {
  summary = 'Different types of audio devices',
  description = [[
    When referencing audio devices, this indicates whether it's the playback or capture device.
  ]],
  values = {
    {
      name = 'playback',
      description = 'The playback device (speakers, headphones).'
    },
    {
      name = 'capture',
      description = 'The capture device (microphone).'
    }
  },
  related = {
    'lovr.audio.getDevices',
    'lovr.audio.setDevice',
    'lovr.audio.start',
    'lovr.audio.stop',
    'lovr.audio.isStarted'
  }
}
