return {
  tag = 'sourceEffects',
  summary = 'Set the position of the Source.',
  description = [[
    Sets the position of the Source, in meters.  Setting the position will cause the Source to be
    distorted and attenuated based on its position relative to the listener.

    Only mono sources can be positioned.  Setting the position of a stereo Source will cause an
    error.
  ]],
  arguments = {
    {
      name = 'x',
      type = 'number',
      description = 'The x coordinate.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y coordinate.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z coordinate.'
    }
  },
  returns = {}
}
