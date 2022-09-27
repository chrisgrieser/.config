return {
  tag = 'graphicsPrimitives',
  summary = 'Draw lines.',
  description = [[
    Draws lines between points.  Each point will be connected to the previous point in the list.
  ]],
  arguments = {
    x1 = {
      type = 'number',
      description = 'The x coordinate of the first point.'
    },
    y1 = {
      type = 'number',
      description = 'The y coordinate of the first point.'
    },
    z1 = {
      type = 'number',
      description = 'The z coordinate of the first point.'
    },
    x2 = {
      type = 'number',
      description = 'The x coordinate of the second point.'
    },
    y2 = {
      type = 'number',
      description = 'The y coordinate of the second point.'
    },
    z2 = {
      type = 'number',
      description = 'The z coordinate of the second point.'
    },
    ['...'] = {
      type = 'number',
      description = 'More points.'
    },
    points = {
      type = 'table',
      description = 'A table of point positions, as described above.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'x1', 'y1', 'z1', 'x2', 'y2', 'z2', '...' },
      returns = {}
    },
    {
      arguments = { 'points' },
      returns = {}
    }
  }
}
