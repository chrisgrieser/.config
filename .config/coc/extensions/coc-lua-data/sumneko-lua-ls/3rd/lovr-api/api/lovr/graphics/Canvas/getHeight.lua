return {
  summary = 'Get the height of the Canvas.',
  description = 'Returns the height of the Canvas, its Textures, and its depth buffer.',
  arguments = {},
  returns = {
    {
      name = 'height',
      type = 'number',
      description = 'The height of the Canvas, in pixels.'
    }
  },
  notes = 'The height of a Canvas can not be changed after it is created.',
  related = {
    'Canvas:getWidth',
    'Canvas:getDimensions'
  }
}
