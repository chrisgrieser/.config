return {
  summary = 'Iterate over unprocessed events in the queue.',
  description = [[
    This function returns a Lua iterator for all of the unprocessed items in the event queue.  Each
    event consists of a name as a string, followed by event-specific arguments.  This function is
    called in the default implementation of `lovr.run`, so it is normally not necessary to poll for
    events yourself.
  ]],
  arguments = {},
  returns = {
    {
      name = 'iterator',
      type = 'function',
      arguments = {},
      returns = {},
      description = 'The iterator function, usable in a for loop.'
    }
  }
}
