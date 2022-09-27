return {
  tag = 'graphicsPrimitives',
  summary = 'Draw one or more points.',
  description = 'Draws one or more points.',
  arguments = {
    x = {
      type = 'number',
      description = 'The x coordinate of the point.'
    },
    y = {
      type = 'number',
      description = 'The y coordinate of the point.'
    },
    z = {
      type = 'number',
      description = 'The z coordinate of the point.'
    },
    ['...'] = {
      type = 'number',
      description = 'More points.'
    },
    points = {
      type = 'table',
      description = 'A table of points, as described above.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'x', 'y', 'z', '...' },
      returns = {}
    },
    {
      arguments = { 'points' },
      returns = {}
    }
  }
}
