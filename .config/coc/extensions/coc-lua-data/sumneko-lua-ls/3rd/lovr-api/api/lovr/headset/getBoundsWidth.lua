return {
  tag = 'playArea',
  summary = 'Get the width of the play area.',
  description = 'Returns the width of the play area, in meters.',
  arguments = {},
  returns = {
    {
      name = 'width',
      type = 'number',
      description = 'The width of the play area, in meters.'
    }
  },
  related = {
    'lovr.headset.getBoundsDepth',
    'lovr.headset.getBoundsDimensions'
  },
  notes = [[
    This currently returns 0 on the Quest.
  ]]
}
