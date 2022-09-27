return {
  tag = 'graphicsTransforms',
  summary = 'Scale the coordinate system.',
  description = [[
    Scales the coordinate system in 3 dimensions.  This will cause objects to appear bigger or
    smaller.

    The scaling will last until `lovr.draw` returns or the transformation is popped off the
    transformation stack.
  ]],
  arguments = {
    {
      name = 'x',
      type = 'number',
      default = '1.0',
      description = 'The amount to scale on the x axis.'
    },
    {
      name = 'y',
      type = 'number',
      default = 'x',
      description = 'The amount to scale on the y axis.'
    },
    {
      name = 'z',
      type = 'number',
      default = 'x',
      description = 'The amount to scale on the z axis.'
    }
  },
  returns = {},
  notes = 'Order matters when scaling, translating, and rotating the coordinate system.',
  related = {
    'lovr.graphics.rotate',
    'lovr.graphics.translate',
    'lovr.graphics.transform'
  }
}
