return {
  tag = 'graphicsPrimitives',
  summary = 'Discard the current pixel values.',
  description = [[
    Discards pixel information in the active Canvas or display.  This is mostly used as an
    optimization hint for the GPU, and is usually most helpful on mobile devices.
  ]],
  arguments = {
    {
      name = 'color',
      type = 'boolean',
      default = 'true',
      description = 'Whether or not to discard color information.'
    },
    {
      name = 'depth',
      type = 'boolean',
      default = 'true',
      description = 'Whether or not to discard depth information.'
    },
    {
      name = 'stencil',
      type = 'boolean',
      default = 'true',
      description = 'Whether or not to discard stencil information.'
    }
  },
  returns = {},
  related = {
    'lovr.graphics.clear'
  }
}
