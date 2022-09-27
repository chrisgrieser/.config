return {
  tag = 'sourcePlayback',
  summary = 'Set the volume of the Source.',
  description = 'Sets the current volume factor for the Source.',
  arguments = {
    {
      name = 'volume',
      type = 'number',
      description = 'The new volume.'
    },
    {
      name = 'units',
      type = 'VolumeUnit',
      default = [['linear']],
      description = 'The units of the value.'
    }
  },
  returns = {},
  notes = 'The volume will be clamped to a 0-1 range (0 dB).'
}
