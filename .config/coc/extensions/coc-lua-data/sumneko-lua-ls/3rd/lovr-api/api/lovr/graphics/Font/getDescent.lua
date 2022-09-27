return {
  summary = 'Get the descent of the Font.',
  description = [[
    Returns the maximum distance that any glyph will extend below the Font's baseline.  Units are
    generally in meters, see `Font:getPixelDensity` for more information.  Note that due to the
    coordinate system for fonts, this is a negative value.
  ]],
  arguments = {},
  returns = {
    {
      name = 'descent',
      type = 'number',
      description = 'The descent of the Font.'
    }
  }
}
