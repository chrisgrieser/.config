return {
  tag = 'sources',
  summary = 'Create a new Source.',
  description = 'Creates a new Source from an ogg, wav, or mp3 file.',
  arguments = {
    filename = {
      type = 'string',
      description = 'The filename of the sound to load.'
    },
    blob = {
      type = 'Blob',
      description = 'The Blob containing the Source data.'
    },
    sound = {
      type = 'Sound',
      description = 'The Sound containing raw audio samples to play.'
    },
    options = {
      type = 'table',
      description = 'Optional options.',
      table = {
        {
          name = 'decode',
          type = 'boolean',
          default = 'false',
          description = 'Whether to immediately decode compressed sounds.'
        },
        {
          name = 'effects',
          type = 'table',
          default = 'true',
          description = [[
            A table of `Effect`s to enable.  Keys can be integers (list) or effect names (map), or a
            combination of both.  The special value `false` can be used to completely disable
            effects, bypassing the spatializer entirely and throwing an error when trying to enable
            effects.  `true` will enable all effects.
          ]]
        }
      }
    }
  },
  returns = {
    source = {
      type = 'Source',
      description = 'The new Source.'
    }
  },
  variants = {
    {
      arguments = { 'filename', 'options' },
      returns = { 'source' }
    },
    {
      arguments = { 'blob', 'options' },
      returns = { 'source' }
    },
    {
      arguments = { 'sound', 'options' },
      returns = { 'source' }
    }
  },
  example = [[
    function lovr.load()
      sandstorm = lovr.audio.newSource('darude.ogg', {
        decode = false,
        effects = { 'spatialization', attenuation = false, reverb = true }
      })

      sandstorm:play()
    end
  ]],
  related = {
    'Source:clone'
  }
}
