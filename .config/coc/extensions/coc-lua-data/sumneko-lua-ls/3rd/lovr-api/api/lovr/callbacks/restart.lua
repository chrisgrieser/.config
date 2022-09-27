return {
  tag = 'callbacks',
  summary = 'Called when restarting.',
  description = [[
    This callback is called when a restart from `lovr.event.restart` is happening.  A value can be
    returned to send it to the next LÖVR instance, available as the `restart` key in the argument
    table passed to `lovr.load`.  Object instances can not be used as the restart value, since they
    are destroyed as part of the cleanup process.
  ]],
  arguments = {},
  returns = {
    {
      type = '*',
      name = 'cookie',
      description = 'The value to send to the next `lovr.load`.'
    }
  },
  notes = [[
    Only nil, booleans, numbers, and strings are supported types for the return value.
  ]],
  example = [[
    function lovr.restart()
      return currentLevel:getName()
    end
  ]],
  related = {
    'lovr.event.restart',
    'lovr.load',
    'lovr.quit'
  }
}
