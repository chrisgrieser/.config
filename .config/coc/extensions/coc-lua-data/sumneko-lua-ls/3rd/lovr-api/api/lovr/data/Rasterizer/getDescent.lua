return {
  summary = 'Get the descent of the font.',
  description = [[
    Returns the descent metric of the font, in pixels.  The descent represents how far any glyph of
    the font descends below the baseline.
  ]],
  arguments = {},
  returns = {
    {
      name = 'descent',
      type = 'number',
      description = 'The descent of the font, in pixels.'
    }
  },
  related = {
    'Rasterzer:getAscent',
    'Font:getDescent'
  }
}
