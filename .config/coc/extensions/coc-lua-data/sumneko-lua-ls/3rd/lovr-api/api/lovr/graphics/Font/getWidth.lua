return {
  summary = 'Measure a line of text.',
  description = [[
    Returns the width and line count of a string when rendered using the font, taking into account
    an optional wrap limit.
  ]],
  arguments = {
    {
      name = 'text',
      type = 'string',
      description = 'The text to get the width of.'
    },
    {
      name = 'wrap',
      type = 'number',
      default = '0',
      description = 'The width at which to wrap lines, or 0 for no wrap.'
    }
  },
  returns = {
    {
      name = 'width',
      type = 'number',
      description = 'The maximum width of any line in the text.'
    },
    {
      name = 'lines',
      type = 'number',
      description = 'The number of lines in the wrapped text.'
    }
  },
  notes = [[
     To get the correct units returned, make sure the pixel density is set with
    `Font:setPixelDensity`.
  ]]
}
