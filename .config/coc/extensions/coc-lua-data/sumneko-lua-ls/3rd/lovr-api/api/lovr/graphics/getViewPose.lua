return {
  tag = 'graphicsState',
  summary = 'Get the camera pose.',
  description = 'Get the pose of a single view.',
  arguments = {
    view = {
      type = 'number',
      description = 'The view index.'
    },
    matrix = {
      type = 'Mat4',
      description = 'The matrix to fill with the view pose.'
    },
    invert = {
      type = 'boolean',
      description = 'Whether the matrix should be inverted.'
    }
  },
  returns = {
    x = {
      type = 'number',
      description = 'The x position of the viewer, in meters.'
    },
    y = {
      type = 'number',
      description = 'The y position of the viewer, in meters.'
    },
    z = {
      type = 'number',
      description = 'The z position of the viewer, in meters.'
    },
    angle = {
      type = 'number',
      description = 'The number of radians the viewer is rotated around its axis of rotation.'
    },
    ax = {
      type = 'number',
      description = 'The x component of the axis of rotation.'
    },
    ay = {
      type = 'number',
      description = 'The y component of the axis of rotation.'
    },
    az = {
      type = 'number',
      description = 'The z component of the axis of rotation.'
    },
    matrix = {
      type = 'Mat4',
      description = 'The matrix containing the view pose.'
    }
  },
  variants = {
    {
      arguments = { 'view' },
      returns = { 'x', 'y', 'z', 'angle', 'ax', 'ay', 'az' }
    },
    {
      arguments = { 'view', 'matrix', 'invert' },
      returns = { 'matrix' }
    }
  },
  related = {
    'lovr.headset.getViewPose',
    'lovr.headset.getViewCount',
    'lovr.graphics.getProjection',
    'lovr.graphics.setProjection'
  }
}
