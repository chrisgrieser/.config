return {
  summary = 'Check if the Sound is compressed.',
  description = [[
    Returns whether the Sound is compressed.  Compressed sounds are loaded from compressed audio
    formats like MP3 and OGG.  They use a lot less memory but require some extra CPU work during
    playback.  Compressed sounds can not be modified using `Sound:setFrames`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'compressed',
      type = 'boolean',
      description = 'Whether the Sound is compressed.'
    }
  },
  related = {
    'Sound:isStream',
    'lovr.data.newSound'
  }
}
