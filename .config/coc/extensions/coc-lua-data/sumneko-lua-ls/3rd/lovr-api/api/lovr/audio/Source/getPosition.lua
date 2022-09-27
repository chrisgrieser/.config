return {
  tag = 'sourceEffects',
  summary = 'Get the position of the Source.',
  description = [[
    Returns the position of the Source, in meters.  Setting the position will cause the Source to
    be distorted and attenuated based on its position relative to the listener.
  ]],
  arguments = {},
  returns = {
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
  related = {
    'Source:getOrientation',
    'Source:getPose',
    'Source:getCone',
    'lovr.audio.getPosition'
  }
}
