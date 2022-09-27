return {
  summary = 'Get the baseline of the Font.',
  description = [[
    Returns the baseline of the Font.  This is where the characters "rest on", relative to the y
    coordinate of the drawn text.  Units are generally in meters, see `Font:setPixelDensity`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'baseline',
      type = 'number',
      description = 'The baseline of the Font.'
    }
  }
}
