return {
  summary = 'Get the width of the Texture.',
  description = 'Returns the width of the Texture.',
  arguments = {
    {
      name = 'mipmap',
      type = 'number',
      default = '1',
      description = 'The mipmap level to get the width of.'
    }
  },
  returns = {
    {
      name = 'width',
      type = 'number',
      description = 'The width of the Texture, in pixels.'
    }
  }
}
