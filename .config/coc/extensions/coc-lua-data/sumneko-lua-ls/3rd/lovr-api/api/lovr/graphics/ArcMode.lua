return {
  summary = 'Different ways arcs can be drawn.',
  description = 'Different ways arcs can be drawn with `lovr.graphics.arc`.',
  values = {
    {
      name = 'pie',
      description = [[
        The arc is drawn with the center of its circle included in the list of points (default).
      ]]
    },
    {
      name = 'open',
      description = 'The curve of the arc is drawn as a single line.'
    },
    {
      name = 'closed',
      description = 'The starting and ending points of the arc\'s curve are connected.'
    }
  }
}
