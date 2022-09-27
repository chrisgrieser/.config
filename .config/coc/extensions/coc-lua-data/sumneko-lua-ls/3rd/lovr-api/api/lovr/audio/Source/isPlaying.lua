return {
  tag = 'sourcePlayback',
  summary = 'Check if the Source is playing.',
  description = 'Returns whether or not the Source is playing.',
  arguments = {},
  returns = {
    {
      name = 'playing',
      type = 'boolean',
      description = 'Whether the Source is playing.'
    }
  },
  related = {
    'Source:play',
    'Source:pause',
    'Source:stop'
  }
}
