return {
  summary = 'Get the format of the Texture.',
  description = [[
    Returns the format of the Texture.  This describes how many color channels are in the texture
    as well as the size of each one.  The most common format used is `rgba`, which contains red,
    green, blue, and alpha color channels.  See `TextureFormat` for all of the possible formats.
  ]],
  arguments = {},
  returns = {
    {
      name = 'format',
      type = 'TextureFormat',
      description = 'The format of the Texture.'
    }
  },
  related = {
    'TextureFormat'
  }
}
