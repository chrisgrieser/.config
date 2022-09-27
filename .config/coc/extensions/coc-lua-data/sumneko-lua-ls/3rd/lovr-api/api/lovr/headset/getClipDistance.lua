return {
  tag = 'headset',
  summary = 'Get the near and far clipping planes of the headset.',
  description = [[
    Returns the near and far clipping planes used to render to the headset.  Objects closer than the
    near clipping plane or further than the far clipping plane will be clipped out of view.
  ]],
  arguments = {},
  returns = {
    {
      name = 'near',
      type = 'number',
      description = 'The distance to the near clipping plane, in meters.'
    },
    {
      name = 'far',
      type = 'number',
      description = 'The distance to the far clipping plane, in meters.'
    }
  },
  notes = [[
    The default near and far clipping planes are 0.1 meters and 100.0 meters.

    This is not currently supported by the `vrapi` headset driver.
  ]]
}
