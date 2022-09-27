return {
  summary = 'Get the current time.',
  description = [[
    Returns the time since some time in the past.  This can be used to measure the difference
    between two points in time.
  ]],
  arguments = {},
  returns = {
    {
      name = 'time',
      type = 'number',
      description = 'The current time, in seconds.'
    }
  },
  related = {
    'lovr.headset.getTime'
  }
}
