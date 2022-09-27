return {
  summary = 'Get the sample format of the Sound.',
  description = 'Returns the sample format of the Sound.',
  arguments = {},
  returns = {
    {
      name = 'format',
      type = 'SampleFormat',
      description = 'The data type of each sample.'
    }
  },
  related = {
    'Sound:getChannelLayout',
    'Sound:getSampleRate'
  }
}
