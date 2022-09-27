return {
  tag = 'playArea',
  summary = 'Get the depth of the play area.',
  description = 'Returns the depth of the play area, in meters.',
  arguments = {},
  returns = {
    {
      name = 'depth',
      type = 'number',
      description = 'The depth of the play area, in meters.'
    }
  },
  related = {
    'lovr.headset.getBoundsWidth',
    'lovr.headset.getBoundsDimensions'
  },
  notes = [[
    This currently returns 0 on the Quest.
  ]]
}
