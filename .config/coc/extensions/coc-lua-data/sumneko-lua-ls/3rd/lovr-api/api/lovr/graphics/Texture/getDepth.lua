return {
  summary = 'Get the depth of the Texture.',
  description = 'Returns the depth of the Texture, or the number of images stored in the Texture.',
  arguments = {
    {
      name = 'mipmap',
      type = 'number',
      default = '1',
      description = 'The mipmap level to get the depth of.  This is only valid for volume textures.'
    }
  },
  returns = {
    {
      name = 'depth',
      type = 'number',
      description = 'The depth of the Texture.'
    }
  }
}
