return {
  summary = 'Get the height of the Texture.',
  description = 'Returns the height of the Texture.',
  arguments = {
    {
      name = 'mipmap',
      type = 'number',
      default = '1',
      description = 'The mipmap level to get the height of.'
    }
  },
  returns = {
    {
      name = 'height',
      type = 'number',
      description = 'The height of the Texture, in pixels.'
    }
  }
}
