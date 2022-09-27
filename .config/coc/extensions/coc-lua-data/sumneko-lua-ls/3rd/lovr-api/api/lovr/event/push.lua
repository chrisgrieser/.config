return {
  summary = 'Manually push an event onto the queue.',
  description = [[
    Pushes an event onto the event queue.  It will be processed the next time `lovr.event.poll` is
    called.  For an event to be processed properly, there needs to be a function in the
    `lovr.handlers` table with a key that's the same as the event name.
  ]],
  arguments = {
    {
      name = 'name',
      type = 'string',
      description = 'The name of the event.'
    },
    {
      name = '...',
      type = '*',
      description = 'The arguments for the event.  Currently, up to 4 are supported.'
    }
  },
  returns = {},
  notes = [[
    Only nil, booleans, numbers, strings, and LÖVR objects are supported types for event data.
  ]],
  related = {
    'lovr.event.poll',
    'lovr.event.quit'
  }
}
