return {
  tag = 'graphicsState',
  summary = 'Get whether alpha sampling is enabled.',
  description = [[
    Returns whether or not alpha sampling is enabled.  Alpha sampling is also known as
    alpha-to-coverage.  When it is enabled, the alpha channel of a pixel is factored into how
    antialiasing is computed, so the edges of a transparent texture will be correctly antialiased.
  ]],
  arguments = {},
  returns = {
    {
      name = 'enabled',
      type = 'boolean',
      description = 'Whether or not alpha sampling is enabled.'
    }
  },
  notes = [[
    - Alpha sampling is disabled by default.
    - This feature can be used for a simple transparency effect, pixels with an alpha of zero will
      have their depth value discarded, allowing things behind them to show through (normally you
      have to sort objects or write a shader for this).
  ]]
}
