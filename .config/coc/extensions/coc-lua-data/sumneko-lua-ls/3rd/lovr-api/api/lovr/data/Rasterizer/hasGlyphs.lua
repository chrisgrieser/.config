return {
  summary = 'Get whether the Rasterizer can rasterize a set of glyphs.',
  description = 'Check if the Rasterizer can rasterize a set of glyphs.',
  arguments = {
    {
      name = '...',
      type = '*',
      description = 'Strings (sets of characters) or numbers (character codes) to check for.'
    }
  },
  returns = {
    {
      name = 'hasGlyphs',
      type = 'boolean',
      description = [[
        true if the Rasterizer can rasterize all of the supplied characters, false otherwise.
      ]]
    }
  },
  related = {
    'Rasterizer:getGlyphCount'
  }
}
