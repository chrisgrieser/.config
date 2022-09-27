return {
  tag = 'graphicsTransforms',
  summary = 'Apply a general transform to the coordinate system.',
  description = [[
    Apply a transform to the coordinate system, changing its translation, rotation, and scale using
    a single function.  A `mat4` can also be used.

    The transformation will last until `lovr.draw` returns or the transformation is popped off the
    transformation stack.
  ]],
  arguments = {
    transform = {
      type = 'mat4',
      description = 'The mat4 to apply to the coordinate system.'
    },
    x = {
      type = 'number',
      default = 0,
      description = 'The x component of the translation.'
    },
    y = {
      type = 'number',
      default = 0,
      description = 'The y component of the translation.'
    },
    z = {
      type = 'number',
      default = 0,
      description = 'The z component of the translation.'
    },
    sx = {
      type = 'number',
      default = 1,
      description = 'The x scale factor.'
    },
    sy = {
      type = 'number',
      default = 1,
      description = 'The y scale factor.'
    },
    sz = {
      type = 'number',
      default = 1,
      description = 'The z scale factor.'
    },
    angle = {
      type = 'number',
      default = 0,
      description = 'The number of radians to rotate around the rotation axis.'
    },
    ax = {
      type = 'number',
      default = 0,
      description = 'The x component of the axis of rotation.'
    },
    ay = {
      type = 'number',
      default = 1,
      description = 'The y component of the axis of rotation.'
    },
    az = {
      type = 'number',
      default = 0,
      description = 'The z component of the axis of rotation.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'x', 'y', 'z', 'sx', 'sy', 'sz', 'angle', 'ax', 'ay', 'az' },
      returns = {}
    },
    {
      description = 'Modify the coordinate system using a mat4 object.',
      arguments = { 'transform' },
      returns = {}
    }
  },
  related = {
    'lovr.graphics.rotate',
    'lovr.graphics.scale',
    'lovr.graphics.translate'
  }
}
