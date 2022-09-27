return {
  summary = 'Quit the application.',
  description = [[
    Pushes an event to quit.  An optional number can be passed to set the exit code for the
    application.  An exit code of zero indicates normal termination, whereas a nonzero exit code
    indicates that an error occurred.
  ]],
  arguments = {
    {
      name = 'code',
      type = 'number',
      default = '0',
      description = 'The exit code of the program.'
    }
  },
  returns = {},
  notes = [[
    This function is equivalent to calling `lovr.event.push('quit', <args>)`.

    The event won't be processed until the next time `lovr.event.poll` is called.

    The `lovr.quit` callback will be called when the event is processed, which can be used to do any
    cleanup work.  The callback can also return `false` to abort the quitting process.
  ]],
  related = {
    'lovr.quit',
    'lovr.event.poll',
    'lovr.event.restart'
  }
}
