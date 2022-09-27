return {
  tag = 'sourcePlayback',
  summary = 'Play the Source.',
  description = 'Plays the Source.  This doesn\'t do anything if the Source is already playing.',
  arguments = {},
  returns = {
    {
      name = 'success',
      type = 'boolean',
      description = 'Whether the Source successfully started playing.'
    }
  },
  notes = [[
    There is a maximum of 64 Sources that can be playing at once.  If 64 Sources are already
    playing, this function will return `false`.
  ]]
}
