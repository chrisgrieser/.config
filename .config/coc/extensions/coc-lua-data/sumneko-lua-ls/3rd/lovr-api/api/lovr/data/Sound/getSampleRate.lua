return {
  summary = 'Get the sample rate of the Sound.',
  description = [[
    Returns the sample rate of the Sound, in Hz.  This is the number of frames that are played every
    second.  It's usually a high number like 48000.
  ]],
  arguments = {},
  returns = {
    {
      name = 'frequency',
      type = 'number',
      description = 'The number of frames per second in the Sound.'
    }
  }
}
