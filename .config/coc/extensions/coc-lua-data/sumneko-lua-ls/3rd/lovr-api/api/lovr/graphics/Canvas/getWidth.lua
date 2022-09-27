return {
  summary = 'Get the width of the Canvas.',
  description = 'Returns the width of the Canvas, its Textures, and its depth buffer.',
  arguments = {},
  returns = {
    {
      name = 'width',
      type = 'number',
      description = 'The width of the Canvas, in pixels.'
    }
  },
  notes = 'The width of a Canvas can not be changed after it is created.',
  related = {
    'Canvas:getHeight',
    'Canvas:getDimensions'
  }
}
