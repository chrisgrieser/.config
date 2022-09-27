return {
  summary = 'Look at a message from the Channel without popping it.',
  description = [[
    Returns a message from the Channel without popping it from the queue.  If the Channel is empty,
    `nil` is returned.  This can be useful to determine if the Channel is empty.
  ]],
  arguments = {},
  returns = {
    {
      name = 'message',
      type = '*',
      description = 'The message, or `nil` if there is no message.'
    },
    {
      name = 'present',
      type = 'boolean',
      description = 'Whether a message was returned (use to detect nil).'
    }
  },
  notes = [[
    The second return value can be used to detect if a `nil` message is in the queue.
  ]],
  related = {
    'Channel:pop'
  }
}
