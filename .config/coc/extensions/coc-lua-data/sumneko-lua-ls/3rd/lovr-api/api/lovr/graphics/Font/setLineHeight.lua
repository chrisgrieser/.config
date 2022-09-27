return {
  summary = 'Set the line height of the Font.',
  description = [[
    Sets the line height of the Font, which controls how far lines apart lines are vertically
    separated.  This value is a ratio and the default is 1.0.
  ]],
  arguments = {
    {
      name = 'lineHeight',
      type = 'number',
      description = 'The new line height.'
    }
  },
  returns = {},
  related = {
    'Font:getHeight',
    'Rasterizer:getLineHeight'
  }
}
