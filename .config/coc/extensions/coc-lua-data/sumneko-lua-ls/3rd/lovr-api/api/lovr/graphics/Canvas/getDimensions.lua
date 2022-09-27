return {
  summary = 'Get the dimensions of the Canvas.',
  description = 'Returns the dimensions of the Canvas, its Textures, and its depth buffer.',
  arguments = {},
  returns = {
    {
      name = 'width',
      type = 'number',
      description = 'The width of the Canvas, in pixels.'
    },
    {
      name = 'height',
      type = 'number',
      description = 'The height of the Canvas, in pixels.'
    }
  },
  notes = 'The dimensions of a Canvas can not be changed after it is created.',
  related = {
    'Canvas:getWidth',
    'Canvas:getHeight'
  }
}
