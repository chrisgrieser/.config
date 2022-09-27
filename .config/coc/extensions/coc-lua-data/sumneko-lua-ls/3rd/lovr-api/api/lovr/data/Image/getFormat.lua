return {
  summary = 'Get the pixel format of the Image.',
  description = 'Returns the format of the Image.',
  arguments = {},
  returns = {
    {
      name = 'format',
      type = 'TextureFormat',
      description = 'The format of the pixels in the Image.'
    }
  },
  related = {
    'TextureFormat',
    'Texture:getFormat'
  }
}
