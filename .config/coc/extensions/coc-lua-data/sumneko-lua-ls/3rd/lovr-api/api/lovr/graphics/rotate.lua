return {
  tag = 'graphicsTransforms',
  summary = 'Rotate the coordinate system.',
  description = [[
    Rotates the coordinate system around an axis.

    The rotation will last until `lovr.draw` returns or the transformation is popped off the
    transformation stack.
  ]],
  arguments = {
    {
      name = 'angle',
      default = '0',
      type = 'number',
      description = 'The amount to rotate the coordinate system by, in radians.'
    },
    {
      name = 'ax',
      type = 'number',
      default = '0',
      description = 'The x component of the axis of rotation.'
    },
    {
      name = 'ay',
      type = 'number',
      default = '1',
      description = 'The y component of the axis of rotation.'
    },
    {
      name = 'az',
      type = 'number',
      default = '0',
      description = 'The z component of the axis of rotation.'
    }
  },
  returns = {},
  notes = 'Order matters when scaling, translating, and rotating the coordinate system.',
  related = {
    'lovr.graphics.scale',
    'lovr.graphics.translate',
    'lovr.graphics.transform'
  }
}
