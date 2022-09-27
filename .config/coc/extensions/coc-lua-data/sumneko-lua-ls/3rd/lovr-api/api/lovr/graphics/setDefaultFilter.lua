return {
  tag = 'graphicsState',
  summary = 'Set the default filter mode for Textures.',
  description = [[
    Sets the default filter mode for new Textures.  This controls how textures are sampled when they
    are minified, magnified, or stretched.
  ]],
  arguments = {
    {
      name = 'mode',
      type = 'FilterMode',
      description = 'The filter mode.'
    },
    {
      name = 'anisotropy',
      type = 'number',
      description = 'The level of anisotropy to use.'
    }
  },
  returns = {},
  notes = [[
    The default filter is `trilinear`.

    The maximum supported anisotropy level can be queried using `lovr.graphics.getLimits`.
  ]],
  related = {
    'Texture:getFilter',
    'Texture:setFilter',
    'lovr.graphics.getLimits'
  }
}
