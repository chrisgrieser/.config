return {
  summary = 'How audio devices are shared on the system.',
  description = [[
    Audio devices can be created in shared mode or exclusive mode.  In exclusive mode, the audio
    device is the only one active on the system, which gives better performance and lower latency.
    However, exclusive devices aren't always supported and might not be allowed, so there is a
    higher chance that creating one will fail.
  ]],
  values = {
    {
      name = 'shared',
      description = 'Shared mode.'
    },
    {
      name = 'exclusive',
      description = 'Exclusive mode.'
    }
  },
  related = {
    'lovr.audio.setDevice'
  }
}
