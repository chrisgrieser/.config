return {
  summary = 'How textures are sampled.',
  description = [[
    The method used to downsample (or upsample) a texture.  "nearest" can be used for a pixelated
    effect, whereas "linear" leads to more smooth results.  Nearest is slightly faster than linear.
  ]],
  values = {
    {
      name = 'nearest',
      description = 'Fast nearest-neighbor sampling.  Leads to a pixelated style.'
    },
    {
      name = 'bilinear',
      description = 'Smooth pixel sampling.'
    },
    {
      name = 'trilinear',
      description = 'Smooth pixel sampling, with smooth sampling across mipmap levels.'
    }
  },
  related = {
    'Texture:getFilter',
    'Texture:setFilter',
    'lovr.graphics.getDefaultFilter',
    'lovr.graphics.setDefaultFilter',
    'WrapMode'
  }
}
