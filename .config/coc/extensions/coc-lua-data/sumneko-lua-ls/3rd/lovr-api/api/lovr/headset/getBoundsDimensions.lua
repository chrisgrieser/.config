return {
  tag = 'playArea',
  summary = 'Get the size of the play area.',
  description = 'Returns the size of the play area, in meters.',
  arguments = {},
  returns = {
    {
      name = 'width',
      type = 'number',
      description = 'The width of the play area, in meters.'
    },
    {
      name = 'depth',
      type = 'number',
      description = 'The depth of the play area, in meters.'
    }
  },
  notes = [[
    This currently returns 0 on the Quest.
  ]],
  related = {
    'lovr.headset.getBoundsWidth',
    'lovr.headset.getBoundsDepth',
    'lovr.headset.getBoundsGeometry'
  }
}
