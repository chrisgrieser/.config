return {
  tag = 'graphicsState',
  summary = 'Get whether each color channel is enabled.',
  description = [[
    Returns a boolean for each color channel (red, green, blue, alpha) indicating whether it is
    enabled.  When a color channel is enabled, it will be affected by drawing commands and clear
    commands.
  ]],
  arguments = {},
  returns = {
    {
      name = 'r',
      type = 'boolean',
      description = 'Whether the red color channel is enabled.'
    },
    {
      name = 'g',
      type = 'boolean',
      description = 'Whether the green color channel is enabled.'
    },
    {
      name = 'b',
      type = 'boolean',
      description = 'Whether the blue color channel is enabled.'
    },
    {
      name = 'a',
      type = 'boolean',
      description = 'Whether the alpha color channel is enabled.'
    }
  },
  returns = {},
  notes = [[
    By default, all color channels are enabled.

    Disabling all of the color channels can be useful if you only want to write to the depth
    buffer or the stencil buffer.
  ]],
  related = {
    'lovr.graphics.stencil'
  }
}
