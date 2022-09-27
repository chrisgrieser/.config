return {
  summary = 'Create a new Thread.',
  description = 'Creates a new Thread from Lua code.',
  arguments = {
    code = {
      type = 'string',
      description = 'The code to run in the Thread.'
    },
    filename = {
      type = 'string',
      description = 'A file containing code to run in the Thread.'
    },
    blob = {
      type = 'Blob',
      description = 'The code to run in the Thread.'
    }
  },
  returns = {
    thread = {
      type = 'Thread',
      description = 'The new Thread.'
    }
  },
  variants = {
    {
      arguments = { 'code' },
      returns = { 'thread' }
    },
    {
      arguments = { 'filename' },
      returns = { 'thread' }
    },
    {
      arguments = { 'blob' },
      returns = { 'thread' }
    }
  },
  notes = [[
    The Thread won\'t start running immediately.  Use `Thread:start` to start it.

    The string argument is assumed to be a filename if there isn't a newline in the first 1024
    characters.  For really short thread code, an extra newline can be added to trick LÖVR into
    loading it properly.
  ]],
  related = {
    'Thread:start',
    'lovr.threaderror'
  }
}
