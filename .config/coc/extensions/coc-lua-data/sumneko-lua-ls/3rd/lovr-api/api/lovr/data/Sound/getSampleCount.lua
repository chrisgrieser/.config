return {
  summary = 'Get the number of samples in the Sound.',
  description = 'Returns the total number of samples in the Sound.',
  arguments = {},
  returns = {
    {
      name = 'samples',
      type = 'number',
      description = 'The total number of samples in the Sound.'
    }
  },
  notes = 'For streams, this returns the number of samples in the stream\'s buffer.',
  related = {
    'Sound:getDuration',
    'Sound:getFrameCount',
    'Sound:getChannelCount'
  }
}
