return {
  tag = 'graphicsState',
  summary = 'Set the line width.',
  description = 'Sets the width of lines rendered using `lovr.graphics.line`.',
  arguments = {
    {
      name = 'width',
      type = 'number',
      default = '1',
      description = 'The new line width, in pixels.'
    }
  },
  returns = {},
  notes = [[
    The default line width is `1`.

    GPU driver support for line widths is poor.  The actual width of lines may be different from
    what is set here.  In particular, some graphics drivers only support a line width of `1`.

    Currently this function only supports integer values from 1 to 255.
  ]],
  related = {
    'lovr.graphics.line'
  }
}
