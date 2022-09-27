return {
  tag = 'headset',
  summary = 'Get the type of tracking origin of the headset.',
  description = [[
    Returns the type of origin used for the tracking volume.  The different types of origins are
    explained on the `HeadsetOrigin` page.
  ]],
  arguments = {},
  returns = {
    {
      name = 'origin',
      type = 'HeadsetOrigin',
      description = 'The type of origin.'
    }
  },
  related = {
    'HeadsetOrigin'
  }
}
