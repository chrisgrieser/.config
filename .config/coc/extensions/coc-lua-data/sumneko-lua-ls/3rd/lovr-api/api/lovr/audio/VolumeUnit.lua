return {
  summary = 'Different units of volume.',
  description = [[
    When accessing the volume of Sources or the audio listener, this can be done in linear units
    with a 0 to 1 range, or in decibels with a range of -∞ to 0.
  ]],
  values = {
    {
      name = 'linear',
      description = 'Linear volume range.'
    },
    {
      name = 'db',
      description = 'Decibels.'
    }
  }
}
