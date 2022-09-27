return {
  tag = 'window',
  summary = 'Check if certain features are supported.',
  description = [[
    Returns whether certain features are supported by the system\'s graphics card.
  ]],
  arguments = {},
  returns = {
    {
      name = 'features',
      type = 'table',
      description = 'A table of features and whether or not they are supported.',
      table = {
        {
          name = 'astc',
          type = 'boolean',
          description = 'Whether ASTC textures are supported.'
        },
        {
          name = 'compute',
          type = 'boolean',
          description = 'Whether compute shaders are available.'
        },
        {
          name = 'dxt',
          type = 'boolean',
          description = 'Whether DXT (.dds) textures are supported.'
        },
        {
          name = 'instancedstereo',
          type = 'boolean',
          description = 'True if the instanced single-pass stereo rendering method is supported.'
        },
        {
          name = 'multiview',
          type = 'boolean',
          description = 'True if the multiview single-pass stereo rendering method is supported.'
        },
        {
          name = 'timers',
          type = 'boolean',
          description = 'Whether `lovr.graphics.tick` and `lovr.graphics.tock` are supported.'
        }
      }
    }
  },
  related = {
    'lovr.graphics.getLimits'
  }
}
