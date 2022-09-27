return {
  summary = 'Get the dimensions of the Image.',
  description = 'Returns the dimensions of the Image, in pixels.',
  arguments = {},
  returns = {
    {
      name = 'width',
      type = 'number',
      description = 'The width of the Image, in pixels.'
    },
    {
      name = 'height',
      type = 'number',
      description = 'The height of the Image, in pixels.'
    }
  },
  related = {
    'Image:getWidth',
    'Image:getHeight',
    'Texture:getDimensions'
  }
}
