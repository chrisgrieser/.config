return {
  tag = 'devices',
  summary = 'Get a list of audio devices.',
  description = [[
    Returns a list of playback or capture devices.  Each device has an `id`, `name`, and a `default`
    flag indicating whether it's the default device.

    To use a specific device id for playback or capture, pass it to `lovr.audio.setDevice`.
  ]],
  arguments = {
    {
      name = 'type',
      type = 'AudioType',
      default = [['playback']],
      description = 'The type of devices to query (playback or capture).'
    }
  },
  returns = {
    {
      name = 'devices',
      type = 'table',
      description = 'The list of devices.',
      table = {
        {
          name = '[].id',
          type = 'userdata',
          description = 'A unique, opaque id for the device.'
        },
        {
          name = '[].name',
          type = 'string',
          description = 'A human readable name for the device.'
        },
        {
          name = '[].default',
          type = 'boolean',
          description = 'Whether the device is the default audio device.'
        }
      }
    }
  },
  related = {
    'lovr.audio.setDevice',
    'lovr.audio.start',
    'lovr.audio.stop'
  }
}
