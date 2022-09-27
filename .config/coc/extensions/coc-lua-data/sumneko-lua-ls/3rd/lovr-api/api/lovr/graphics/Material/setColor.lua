return {
  summary = 'Set a color property of the Material.',
  description = [[
    Sets a color property for a Material.  Different types of colors are supported for different
    lighting parameters.  Colors default to `(1.0, 1.0, 1.0, 1.0)` and are gamma corrected.
  ]],
  arguments = {
    colorType = {
      type = 'MaterialColor',
      default = [['diffuse']],
      description = 'The type of color to set.'
    },
    r = {
      type = 'number',
      description = 'The red component of the color.'
    },
    g = {
      type = 'number',
      description = 'The green component of the color.'
    },
    b = {
      type = 'number',
      description = 'The blue component of the color.'
    },
    hex = {
      type = 'number',
      description = 'A hexcode to use for the color.'
    },
    a = {
      type = 'number',
      default = '1.0',
      description = 'The alpha component of the color.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'colorType', 'r', 'g', 'b', 'a' },
      returns = {}
    },
    {
      arguments = { 'r', 'g', 'b', 'a' },
      returns = {}
    },
    {
      arguments = { 'colorType', 'hex', 'a' },
      returns = {}
    },
    {
      arguments = { 'hex', 'a' },
      returns = {}
    }
  },
  related = {
    'MaterialColor',
    'lovr.graphics.setColor'
  }
}
