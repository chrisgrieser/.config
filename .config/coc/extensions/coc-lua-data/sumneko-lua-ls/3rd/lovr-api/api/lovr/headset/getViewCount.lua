return {
  tag = 'headset',
  summary = 'Get the number of views used for rendering.',
  description = [[
    Returns the number of views used for rendering.  Each view consists of a pose in space and a set
    of angle values that determine the field of view.

    This is usually 2 for stereo rendering configurations, but it can also be different.  For
    example, one way of doing foveated rendering uses 2 views for each eye -- one low quality view
    with a wider field of view, and a high quality view with a narrower field of view.
  ]],
  arguments = {},
  returns = {
    {
      name = 'count',
      type = 'number',
      description = 'The number of views.'
    }
  },
  related = {
    'lovr.headset.getViewPose',
    'lovr.headset.getViewAngles'
  }
}
