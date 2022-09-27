return {
  summary = 'Check if a Font has a set of glyphs.',
  description = [[
    Returns whether the Font has a set of glyphs.  Any combination of strings and numbers
    (corresponding to character codes) can be specified.  This function will return true if the
    Font is able to render *all* of the glyphs.
  ]],
  arguments = {
    {
      name = '...',
      type = '*',
      description = 'Strings or numbers to test.'
    }
  },
  returns = {
    {
      name = 'has',
      type = 'boolean',
      description = 'Whether the Font has the glyphs.'
    }
  },
  notes = [[
    It is a good idea to use this function when you're rendering an unknown or user-supplied string
    to avoid utterly embarrassing crashes.
  ]],
  related = {
    'Rasterizer:hasGlyphs'
  }
}
