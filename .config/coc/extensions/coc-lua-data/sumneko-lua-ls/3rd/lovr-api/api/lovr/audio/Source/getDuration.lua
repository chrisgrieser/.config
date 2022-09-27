return {
  tag = 'sourcePlayback',
  summary = 'Get the duration of the Source.',
  description = 'Returns the duration of the Source.',
  arguments = {
    {
      name = 'unit',
      type = 'TimeUnit',
      default = [['seconds']],
      description = 'The unit to return.'
    }
  },
  returns = {
    {
      name = 'duration',
      type = 'number',
      description = 'The duration of the Source.'
    }
  },
  related = {
    'Sound:getDuration'
  }
}
