return {
  tag = 'graphicsState',
  summary = 'Set the background color.',
  description = [[
    Sets the background color used to clear the screen.  Color components are from 0.0 to 1.0.
  ]],
  arguments = {
    r = {
      type = 'number',
      description = 'The red component of the background color.'
    },
    g = {
      type = 'number',
      description = 'The green component of the background color.'
    },
    b = {
      type = 'number',
      description = 'The blue component of the background color.'
    },
    hex = {
      type = 'number',
      description = 'A hexcode like `0xffffff` to use for the background.'
    },
    a = {
      type = 'number',
      default = '1.0',
      description = 'The alpha component of the background color.'
    },
    color = {
      type = 'table',
      description = 'A table containing 3 or 4 color components.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'r', 'g', 'b', 'a' },
      returns = {}
    },
    {
      arguments = { 'hex', 'a' },
      returns = {}
    },
    {
      arguments = { 'color' },
      returns = {}
    }
  },
  notes = 'The default background color is `(0.0, 0.0, 0.0, 1.0)`.'
}
