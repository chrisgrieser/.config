return {
  tag = 'sourceEffects',
  summary = 'Check if an effect is enabled.',
  description = 'Returns whether a given `Effect` is enabled for the Source.',
  arguments = {
    {
      name = 'effect',
      type = 'Effect',
      description = 'The effect.'
    }
  },
  returns = {
    {
      name = 'enabled',
      type = 'boolean',
      description = 'Whether the effect is enabled.'
    }
  },
  notes = [[
    The active spatializer will determine which effects are supported.  If an unsupported effect is
    enabled on a Source, no error will be reported.  Instead, it will be silently ignored.  See
    `lovr.audio.getSpatializer` for a table showing the effects supported by each spatializer.

    Calling this function on a Source that was created with `{ effects = false }` will always return
    false.
  ]]
}
