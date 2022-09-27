return {
  tag = 'graphicsState',
  summary = 'Get the field of view.',
  description = 'Returns the projection for a single view.',
  arguments = {
    view = {
      type = 'number',
      description = 'The view index.'
    },
    matrix = {
      type = 'Mat4',
      description = 'The matrix to fill with the projection.'
    }
  },
  returns = {
    left = {
      type = 'number',
      description = 'The left field of view angle, in radians.'
    },
    right = {
      type = 'number',
      description = 'The right field of view angle, in radians.'
    },
    up = {
      type = 'number',
      description = 'The top field of view angle, in radians.'
    },
    down = {
      type = 'number',
      description = 'The bottom field of view angle, in radians.'
    },
    matrix = {
      type = 'Mat4',
      description = 'The matrix containing the projection.'
    }
  },
  variants = {
    {
      arguments = { 'view' },
      returns = { 'left', 'right', 'up', 'down' }
    },
    {
      arguments = { 'view', 'matrix' },
      returns = { 'matrix' }
    }
  },
  notes = [[
    Non-stereo rendering will only use the first view.

    The projection matrices are available as the `mat4 lovrProjections[2]` variable in shaders.  The
    current projection matrix is available as `lovrProjection`.
  ]],
  related = {
    'lovr.headset.getViewAngles',
    'lovr.headset.getViewCount',
    'lovr.graphics.getViewPose',
    'lovr.graphics.setViewPose'
  }
}
