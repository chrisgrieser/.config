return {
  summary = 'Get the pixel density of the Font.',
  description = [[
    Returns the current pixel density for the Font.  The default is 1.0.  Normally, this is in
    pixels per meter.  When rendering to a 2D texture, the units are pixels.
  ]],
  arguments = {},
  returns = {
    {
      name = 'pixelDensity',
      type = 'number',
      description = 'The current pixel density.'
    }
  }
}
