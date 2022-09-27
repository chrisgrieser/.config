return {
  tag = 'graphicsState',
  summary = 'Set the stencil test.',
  description = [[
    Sets the stencil test.  The stencil test lets you mask out pixels that meet certain criteria,
    based on the contents of the stencil buffer.  The stencil buffer can be modified using
    `lovr.graphics.stencil`.  After rendering to the stencil buffer, the stencil test can be set to
    control how subsequent drawing functions are masked by the stencil buffer.
  ]],
  arguments = {
    compareMode = {
      type = 'CompareMode',
      description = [[
        The comparison method used to decide if a pixel should be visible, or nil if the stencil
        test is disabled.
      ]]
    },
    compareValue = {
      type = 'number',
      description = 'The value to compare stencil values to.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'compareMode', 'compareValue' },
      returns = {}
    },
    {
      description = 'Disables the stencil test.',
      arguments = {},
      returns = {}
    }
  },
  notes = [[
    Stencil values are between 0 and 255.

    By default, the stencil test is disabled.
  ]],
  related = {
    'lovr.graphics.stencil'
  }
}
