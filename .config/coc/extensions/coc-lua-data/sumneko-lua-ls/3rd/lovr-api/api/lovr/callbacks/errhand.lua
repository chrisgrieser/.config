return {
  tag = 'callbacks',
  summary = 'Called when an error occurs.',
  description = [[
    The "lovr.errhand" callback is run whenever an error occurs.  It receives two
    parameters. The first is a string containing the error message. The second is either
    nil, or a string containing a traceback (as returned by "debug.traceback()"); if nil,
    this means "lovr.errhand" is being called in the stack where the error occurred,
    and it can call "debug.traceback()" itself.

    "lovr.errhand" should return a handler function to run in a loop to show
    the error screen. This handler function is of the same type as the one returned by
    "lovr.run" and has the same requirements (such as pumping events). If an error occurs
    while this handler is running, the program will terminate immediately--
    "lovr.errhand" will not be given a second chance. Errors which occur inside "lovr.errhand"
    or in the handler it returns may not be cleanly reported, so be careful.

    A default error handler is supplied that renders the error message as text to the headset and
    to the window.
  ]],
  arguments = {
    {
      name = 'message',
      type = 'string',
      description = 'The error message.'
    },
    {
      name = 'traceback',
      type = 'string',
      description = 'A traceback string, or nil.'
    }
  },
  returns = {
    {
      name = 'handler',
      type = 'function',
      arguments = {},
      returns = {
        {
          name = 'result',
          type = '*'
        }
      },
      description = [[
        The error handler function.  It should return nil to continue running, "restart" to restart the
        app, or a number representing an exit status.
      ]]
    }
  },
  example = [[
    function lovr.errhand(message, traceback)
      traceback = traceback or debug.traceback('', 3)
      print('ohh NOOOO!', message)
      print(traceback)
      return function()
        lovr.graphics.print('There was an error', 0, 2, -5)
      end
    end
  ]],
  related = {
    'lovr.quit'
  }
}
