return {
  tag = 'listener',
  summary = 'Get the position of the listener.',
  description = 'Returns the position of the virtual audio listener, in meters.',
  arguments = {},
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'The x position of the listener.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y position of the listener.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z position of the listener.'
    }
  }
}
