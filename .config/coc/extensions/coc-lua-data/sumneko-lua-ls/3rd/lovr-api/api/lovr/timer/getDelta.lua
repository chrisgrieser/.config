return {
  summary = 'Get the time elapsed since the last update.',
  description = [[
    Returns the time between the last two frames.  This is the same value as the `dt` argument
    provided to `lovr.update`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'dt',
      type = 'number',
      description = 'The delta time, in seconds.'
    }
  },
  notes = [[
    The return value of this function will remain the same until `lovr.timer.step` is called.  This
    function should not be used to measure times for game behavior or benchmarking, use
    `lovr.timer.getTime` for that.
  ]],
  related = {
    'lovr.timer.getTime',
    'lovr.update'
  }
}
