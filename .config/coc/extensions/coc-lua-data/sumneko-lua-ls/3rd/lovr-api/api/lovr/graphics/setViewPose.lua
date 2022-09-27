return {
  tag = 'graphicsState',
  summary = 'Set the camera pose.',
  description = [[
    Sets the pose for a single view.  Objects rendered in this view will appear as though the camera
    is positioned using the given pose.

    Two views are supported, one for each eye.  When rendering to the headset, both views are
    changed to match the estimated eye positions.  These view poses are also available using
    `lovr.headset.getViewPose`.
  ]],
  arguments = {
    view = {
      type = 'number',
      description = 'The index of the view to update.'
    },
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
      description = 'A matrix containing the viewer pose.'
    },
    inverted = {
      type = 'boolean',
      description = 'Whether the matrix is an inverted pose (a view matrix).'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'view', 'x', 'y', 'z', 'angle', 'ax', 'ay', 'az' },
      returns = {}
    },
    {
      arguments = { 'view', 'matrix', 'inverted' },
      returns = {}
    }
  },
  notes = [[
    Non-stereo rendering will only use the first view.

    The inverted view poses (view matrices) are available as the `mat4 lovrViews[2]` variable in
    shaders.  The current view matrix is available as `lovrView`.
  ]],
  related = {
    'lovr.headset.getViewPose',
    'lovr.headset.getViewCount',
    'lovr.graphics.getProjection',
    'lovr.graphics.setProjection'
  }
}
