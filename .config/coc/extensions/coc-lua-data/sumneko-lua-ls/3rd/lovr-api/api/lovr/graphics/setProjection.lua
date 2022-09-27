return {
  tag = 'graphicsState',
  summary = 'Set the field of view.',
  description = [[
    Sets the projection for a single view.  4 field of view angles can be used, similar to the field
    of view returned by `lovr.headset.getViewAngles`.  Alternatively, a projection matrix can be
    used for other types of projections like orthographic, oblique, etc.

    Two views are supported, one for each eye.  When rendering to the headset, both projections are
    changed to match the ones used by the headset.
  ]],
  arguments = {
    view = {
      type = 'number',
      description = 'The index of the view to update.'
    },
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
      description = 'The projection matrix for the view.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'view', 'left', 'right', 'up', 'down' },
      returns = {}
    },
    {
      arguments = { 'view', 'matrix' },
      returns = {}
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
