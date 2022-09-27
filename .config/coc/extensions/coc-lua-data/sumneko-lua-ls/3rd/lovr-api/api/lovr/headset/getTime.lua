return {
  summary = 'Get the predicted display time.',
  description = [[
    Returns the estimated time in the future at which the light from the pixels of the current frame
    will hit the eyes of the user.

    This can be used as a replacement for `lovr.timer.getTime` for timestamps that are used for
    rendering to get a smoother result that is synchronized with the display of the headset.
  ]],
  arguments = {},
  returns = {
    {
      name = 'time',
      type = 'number',
      description = 'The predicted display time, in seconds.'
    }
  },
  notes = [[
    This has a different epoch than `lovr.timer.getTime`, so it is not guaranteed to be close to
    that value.
  ]],
  related = {
    'lovr.timer.getTime'
  }
}
