return {
  tag = 'graphicsState',
  summary = 'Enable or disable alpha sampling.',
  description = [[
    Enables or disables alpha sampling.  Alpha sampling is also known as alpha-to-coverage.  When it
    is enabled, the alpha channel of a pixel is factored into how antialiasing is computed, so the
    edges of a transparent texture will be correctly antialiased.
  ]],
  arguments = {
    {
      name = 'enabled',
      type = 'boolean',
      description = 'Whether or not alpha sampling is enabled.'
    }
  },
  returns = {},
  notes = [[
    - Alpha sampling is disabled by default.
    - This feature can be used for a simple transparency effect, pixels with an alpha of zero will
      have their depth value discarded, allowing things behind them to show through (normally you
      have to sort objects or write a shader for this).
  ]]
}
