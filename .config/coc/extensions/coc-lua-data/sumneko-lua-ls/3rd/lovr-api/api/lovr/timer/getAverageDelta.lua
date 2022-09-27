return {
  summary = 'Get the average delta over the last second.',
  description = 'Returns the average delta over the last second.',
  arguments = {},
  returns = {
    {
      name = 'delta',
      type = 'number',
      description = 'The average delta, in seconds.'
    }
  },
  related = {
    'lovr.timer.getDelta',
    'lovr.update'
  }
}
