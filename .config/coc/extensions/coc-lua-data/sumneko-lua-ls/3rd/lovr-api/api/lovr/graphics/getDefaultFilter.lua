return {
  tag = 'graphicsState',
  summary = 'Get the default filter mode for Textures.',
  description = [[
    Returns the default filter mode for new Textures.  This controls how textures are sampled when
    they are minified, magnified, or stretched.
  ]],
  arguments = {},
  returns = {
    {
      name = 'mode',
      type = 'FilterMode',
      description = 'The filter mode.'
    },
    {
      name = 'anisotropy',
      type = 'number',
      description = 'The level of anisotropy.'
    }
  },
  notes = 'The default filter is `trilinear`.',
  related = {
    'Texture:getFilter',
    'Texture:setFilter'
  }
}
