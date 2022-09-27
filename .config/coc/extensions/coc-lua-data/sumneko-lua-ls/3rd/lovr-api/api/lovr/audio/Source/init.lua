return {
  summary = 'A playable sound object.',
  description = [[
    A Source is an object representing a single sound.  Currently ogg, wav, and mp3 formats are
    supported.

    When a Source is playing, it will send audio to the speakers.  Sources do not play automatically
    when they are created.  Instead, the `play`, `pause`, and `stop` functions can be used to
    control when they should play.

    `Source:seek` and `Source:tell` can be used to control the playback position of the Source.  A
    Source can be set to loop when it reaches the end using `Source:setLooping`.
  ]],
  constructors = {
    'lovr.audio.newSource',
    'Source:clone'
  },
  sections = {
    {
      name = 'Playback',
      tag = 'sourcePlayback'
    },
    {
      name = 'Spatial Effects',
      tag = 'sourceEffects'
    },
    {
      name = 'Utility',
      tag = 'sourceUtility'
    }
  }
}
