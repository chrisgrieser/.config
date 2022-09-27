return {
  summary = 'Get the advance of the font.',
  description = [[
    Returns the advance metric of the font, in pixels.  The advance is how many pixels the font
    advances horizontally after each glyph is rendered.  This does not include kerning.
  ]],
  arguments = {},
  returns = {
    {
      name = 'advance',
      type = 'number',
      description = 'The advance of the font, in pixels.'
    }
  }
}
