return {
  tag = 'sourcePlayback',
  summary = 'Get the playback position of the Source.',
  description = 'Returns the current playback position of the Source.',
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
      name = 'position',
      type = 'number',
      description = 'The current playback position.'
    }
  },
  notes = 'The return value for Sources backed by a stream `Sound` has no meaning.'
}
