return {
  summary = 'Go to sleep.',
  description = [[
    Sleeps the application for a specified number of seconds.  While the game is asleep, no code
    will be run, no graphics will be drawn, and the window will be unresponsive.
  ]],
  arguments = {
    {
      name = 'duration',
      type = 'number',
      description = 'The number of seconds to sleep for.'
    }
  },
  returns = {}
}
