return {
  summary = 'Different blend modes.',
  description = [[
    Blend modes control how overlapping pixels are blended together, similar to layers in Photoshop.
  ]],
  values = {
    {
      name = 'alpha',
      description = 'Normal blending where the alpha value controls how the colors are blended.'
    },
    {
      name = 'add',
      description = 'The incoming pixel color is added to the destination pixel color.'
    },
    {
      name = 'subtract',
      description = 'The incoming pixel color is subtracted from the destination pixel color.'
    },
    {
      name = 'multiply',
      description = [[
        The color channels from the two pixel values are multiplied together to produce a result.
      ]]
    },
    {
      name = 'lighten',
      description = [[
        The maximum value from each color channel is used, resulting in a lightening effect.
      ]]
    },
    {
      name = 'darken',
      description = [[
        The minimum value from each color channel is used, resulting in a darkening effect.
      ]]
    },
    {
      name = 'screen',
      description = [[
        The opposite of multiply: The pixel values are inverted, multiplied, and inverted again,
        resulting in a lightening effect.
      ]]
    }
  },
  related = {
    'BlendAlphaMode',
    'lovr.graphics.getBlendMode',
    'lovr.graphics.setBlendMode'
  }
}
