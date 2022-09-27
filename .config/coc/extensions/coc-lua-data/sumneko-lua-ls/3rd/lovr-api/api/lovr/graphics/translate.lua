return {
  tag = 'graphicsTransforms',
  summary = 'Translate the coordinate system.',
  description = [[
    Translates the coordinate system in three dimensions.  All graphics operations that use
    coordinates will behave as if they are offset by the translation value.

    The translation will last until `lovr.draw` returns or the transformation is popped off the
    transformation stack.
  ]],
  arguments = {
    {
      name = 'x',
      type = 'number',
      default = '0',
      description = 'The amount to translate on the x axis.'
    },
    {
      name = 'y',
      type = 'number',
      default = '0',
      description = 'The amount to translate on the y axis.'
    },
    {
      name = 'z',
      type = 'number',
      default = '0',
      description = 'The amount to translate on the z axis.'
    }
  },
  returns = {},
  notes = 'Order matters when scaling, translating, and rotating the coordinate system.',
  related = {
    'lovr.graphics.rotate',
    'lovr.graphics.scale',
    'lovr.graphics.transform'
  }
}
