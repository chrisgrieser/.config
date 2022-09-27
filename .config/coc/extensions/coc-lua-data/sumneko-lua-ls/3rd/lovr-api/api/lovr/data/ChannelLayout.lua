return {
  summary = 'Different channel layouts for Sounds.',
  description = [[
    Sounds can have different numbers of channels, and those channels can map to various speaker
    layouts.
  ]],
  values = {
    {
      name = 'mono',
      description = '1 channel.'
    },
    {
      name = 'stereo',
      description = [[
        2 channels.  The first channel is for the left speaker and the second is for the right.
      ]]
    },
    {
      name = 'ambisonic',
      description = [[
        4 channels.  Ambisonic channels don't map directly to speakers but instead represent
        directions in 3D space, sort of like the images of a skybox.  Currently, ambisonic sounds
        can only be loaded, not played.  
      ]]
    }
  },
  related = {
    'lovr.data.newSound',
    'Sound:getFormat'
  }
}
