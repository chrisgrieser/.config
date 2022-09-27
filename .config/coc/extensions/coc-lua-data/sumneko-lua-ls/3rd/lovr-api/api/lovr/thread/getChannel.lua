return {
  summary = 'Get a Channel for communicating between threads.',
  description = 'Returns a named Channel for communicating between threads.',
  arguments = {
    {
      name = 'name',
      type = 'string',
      description = 'The name of the Channel to get.'
    }
  },
  returns = {
    {
      name = 'channel',
      type = 'Channel',
      description = 'The Channel with the specified name.'
    }
  },
  related = {
    'Channel'
  }
}
