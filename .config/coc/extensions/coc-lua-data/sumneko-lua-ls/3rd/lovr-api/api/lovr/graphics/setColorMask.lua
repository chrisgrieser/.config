return {
  tag = 'graphicsState',
  summary = 'Enable or disable color channels.',
  description = [[
    Enables and disables individual color channels.  When a color channel is enabled, it will be
    affected by drawing commands and clear commands.
  ]],
  arguments = {
    {
      name = 'r',
      type = 'boolean',
      description = 'Whether the red color channel should be enabled.'
    },
    {
      name = 'g',
      type = 'boolean',
      description = 'Whether the green color channel should be enabled.'
    },
    {
      name = 'b',
      type = 'boolean',
      description = 'Whether the blue color channel should be enabled.'
    },
    {
      name = 'a',
      type = 'boolean',
      description = 'Whether the alpha color channel should be enabled.'
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
