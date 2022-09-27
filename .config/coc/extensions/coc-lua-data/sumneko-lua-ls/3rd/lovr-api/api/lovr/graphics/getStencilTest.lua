return {
  tag = 'graphicsState',
  summary = 'Get the current stencil test.',
  description = [[
    Returns the current stencil test.  The stencil test lets you mask out pixels that meet certain
    criteria, based on the contents of the stencil buffer.  The stencil buffer can be modified using
    `lovr.graphics.stencil`.  After rendering to the stencil buffer, the stencil test can be set to
    control how subsequent drawing functions are masked by the stencil buffer.
  ]],
  arguments = {},
  returns = {
    {
      name = 'compareMode',
      type = 'CompareMode',
      description = [[
        The comparison method used to decide if a pixel should be visible, or nil if the stencil
        test is disabled.
      ]]
    },
    {
      name = 'compareValue',
      type = 'number',
      description = [[
        The value stencil values are compared against, or nil if the stencil test is disabled.
      ]]
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
