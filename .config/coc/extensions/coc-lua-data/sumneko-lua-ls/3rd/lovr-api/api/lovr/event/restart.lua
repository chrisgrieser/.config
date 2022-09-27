return {
  summary = 'Restart the application.',
  description = 'Pushes an event to restart the framework.',
  arguments = {},
  returns = {},
  notes = [[
    The event won't be processed until the next time `lovr.event.poll` is called.

    The `lovr.restart` callback can be used to persist a value between restarts.
  ]],
  related = {
    'lovr.restart',
    'lovr.event.poll',
    'lovr.event.quit'
  }
}
