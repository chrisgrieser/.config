return {
  tag = 'listener',
  summary = 'Get the master volume.',
  description = [[
    Returns the master volume.  All audio sent to the playback device has its volume multiplied by
    this factor.
  ]],
  arguments = {
    {
      name = 'units',
      type = 'VolumeUnit',
      default = [['linear']],
      description = 'The units to return (linear or db).'
    }
  },
  returns = {
    {
      name = 'volume',
      type = 'number',
      description = 'The master volume.'
    }
  },
  notes = 'The default volume is 1.0 (0 dB).'
}
