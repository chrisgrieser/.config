return {
  tag = 'graphicsState',
  summary = 'Set the global color factor.',
  description = [[
    Sets the color used for drawing objects.  Color components are from 0.0 to 1.0.  Every pixel drawn
    will be multiplied (i.e. tinted) by this color.  This is a global setting, so it will affect all
    subsequent drawing operations.
  ]],
  arguments = {
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
      description = 'A hexcode like `0xffffff` to use for the color.'
    },
    a = {
      type = 'number',
      default = '1.0',
      description = 'The alpha component of the color.'
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
  notes = 'The default color is `(1.0, 1.0, 1.0, 1.0)`.',
  example = {
    description = 'Draw a red cube.',
    code = [[
      function lovr.draw()
        lovr.graphics.setColor(1.0, 0, 0)
        lovr.graphics.cube('fill', 0, 1.7, -1, .5, lovr.timer.getTime())
      end
    ]]
  }
}
