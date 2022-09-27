return {
  tag = 'graphicsPrimitives',
  summary = 'Draw an arc.',
  description = 'Draws an arc.',
  arguments = {
    mode = {
      type = 'DrawStyle',
      description = 'Whether the arc is filled or outlined.'
    },
    arcmode = {
      type = 'ArcMode',
      default = [['pie']],
      description = 'How to draw the arc.'
    },
    material = {
      type = 'Material',
      description = 'The Material to apply to the arc.'
    },
    transform = {
      type = 'mat4',
      description = 'The arc\'s transform.'
    },
    x = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the center of the arc.'
    },
    y = {
      type = 'number',
      default = '0',
      description = 'The y coordinate of the center of the arc.'
    },
    z = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the center of the arc.'
    },
    radius = {
      type = 'number',
      default = '1',
      description = 'The radius of the arc, in meters.'
    },
    angle = {
      type = 'number',
      default = '0',
      description = 'The rotation of the arc around its rotation axis, in radians.'
    },
    ax = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the arc\'s axis of rotation.'
    },
    ay = {
      type = 'number',
      default = '1',
      description = 'The y coordinate of the arc\'s axis of rotation.'
    },
    az = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the arc\'s axis of rotation.'
    },
    start = {
      type = 'number',
      default = '0',
      description = 'The starting angle of the arc, in radians.'
    },
    ['end'] = {
      type = 'number',
      default = '2 * math.pi',
      description = 'The ending angle of the arc, in radians.'
    },
    segments = {
      type = 'number',
      default = '32',
      description = [[
        The number of segments to use for the full circle. A smaller number of segments will be
        used, depending on how long the arc is.
      ]]
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'mode', 'x', 'y', 'z', 'radius', 'angle', 'ax', 'ay', 'az', 'start', 'end', 'segments' },
      returns = {}
    },
    {
      arguments = { 'material', 'x', 'y', 'z', 'radius', 'angle', 'ax', 'ay', 'az', 'start', 'end', 'segments' },
      returns = {}
    },
    {
      arguments = { 'mode', 'transform', 'start', 'end', 'segments' },
      returns = {}
    },
    {
      arguments = { 'material', 'transform', 'start', 'end', 'segments' },
      returns = {}
    },
    {
      arguments = { 'mode', 'arcmode', 'x', 'y', 'z', 'radius', 'angle', 'ax', 'ay', 'az', 'start', 'end', 'segments' },
      returns = {}
    },
    {
      arguments = { 'material', 'arcmode', 'x', 'y', 'z', 'radius', 'angle', 'ax', 'ay', 'az', 'start', 'end', 'segments' },
      returns = {}
    },
    {
      arguments = { 'mode', 'arcmode', 'transform', 'start', 'end', 'segments' },
      returns = {}
    },
    {
      arguments = { 'material', 'arcmode', 'transform', 'start', 'end', 'segments' },
      returns = {}
    }
  },
  notes = 'The local normal vector of the circle is `(0, 0, 1)`.',
  related = {
    'lovr.graphics.arc'
  }
}
