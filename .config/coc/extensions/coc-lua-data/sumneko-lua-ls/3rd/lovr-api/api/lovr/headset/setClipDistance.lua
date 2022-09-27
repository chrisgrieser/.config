return {
  tag = 'headset',
  summary = 'Set the near and far clipping planes of the headset.',
  description = [[
    Sets the near and far clipping planes used to render to the headset.  Objects closer than the
    near clipping plane or further than the far clipping plane will be clipped out of view.
  ]],
  arguments = {
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
  returns = {},
  notes = 'The default clip distances are 0.1 and 100.0.'
}
