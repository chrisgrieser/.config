return {
  summary = 'Get the dimensions of the Texture.',
  description = 'Returns the dimensions of the Texture.',
  arguments = {
    {
      name = 'mipmap',
      type = 'number',
      default = '1',
      description = 'The mipmap level to get the dimensions of.'
    }
  },
  returns = {
    {
      name = 'width',
      type = 'number',
      description = 'The width of the Texture, in pixels.'
    },
    {
      name = 'height',
      type = 'number',
      description = 'The height of the Texture, in pixels.'
    },
    {
      name = 'depth',
      type = 'number',
      description = 'The number of images stored in the Texture, for non-2D textures.'
    }
  }
}
