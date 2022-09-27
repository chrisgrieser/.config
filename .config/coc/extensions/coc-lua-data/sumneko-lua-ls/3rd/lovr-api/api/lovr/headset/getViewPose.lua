return {
  tag = 'headset',
  summary = 'Get the pose of one of the views.',
  description = [[
    Returns the pose of one of the headset views.  This info can be used to create view matrices or
    do other eye-dependent calculations.

    If tracking data is unavailable for the view or the index is invalid, `nil` is returned.
  ]],
  arguments = {
    {
      name = 'view',
      type = 'number',
      description = 'The view index.'
    }
  },
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'The x coordinate of the view position, in meters.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y coordinate of the view position, in meters.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z coordinate of the view position, in meters.'
    },
    {
      name = 'angle',
      type = 'number',
      description = 'The amount of rotation around the rotation axis, in radians.'
    },
    {
      name = 'ax',
      type = 'number',
      description = 'The x component of the axis of rotation.'
    },
    {
      name = 'ay',
      type = 'number',
      description = 'The y component of the axis of rotation.'
    },
    {
      name = 'az',
      type = 'number',
      description = 'The z component of the axis of rotation.'
    }
  },
  related = {
    'lovr.headset.getViewCount',
    'lovr.headset.getViewAngles'
  }
}
