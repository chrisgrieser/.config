return {
  tag = 'graphicsPrimitives',
  summary = 'Draw a 2D circle.',
  description = 'Draws a 2D circle.',
  arguments = {
    mode = {
      type = 'DrawStyle',
      description = 'Whether the circle is filled or outlined.'
    },
    material = {
      type = 'Material',
      description = 'The Material to apply to the circle.'
    },
    transform = {
      type = 'mat4',
      description = 'The circle\'s transform.'
    },
    x = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the center of the circle.'
    },
    y = {
      type = 'number',
      default = '0',
      description = 'The y coordinate of the center of the circle.'
    },
    z = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the center of the circle.'
    },
    radius = {
      type = 'number',
      default = '1',
      description = 'The radius of the circle, in meters.'
    },
    angle = {
      type = 'number',
      default = '0',
      description = 'The rotation of the circle around its rotation axis, in radians.'
    },
    ax = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the circle\'s axis of rotation.'
    },
    ay = {
      type = 'number',
      default = '1',
      description = 'The y coordinate of the circle\'s axis of rotation.'
    },
    az = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the circle\'s axis of rotation.'
    },
    segments = {
      type = 'number',
      default = '32',
      description = [[
        The number of segments to use for the circle geometry.  Higher numbers increase smoothness
        but increase rendering cost slightly.
      ]]
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'mode', 'x', 'y', 'z', 'radius', 'angle', 'ax', 'ay', 'az', 'segments' },
      returns = {}
    },
    {
      arguments = { 'material', 'x', 'y', 'z', 'radius', 'angle', 'ax', 'ay', 'az', 'segments' },
      returns = {}
    },
    {
      arguments = { 'mode', 'transform', 'segments' },
      returns = {}
    },
    {
      arguments = { 'material', 'transform', 'segments' },
      returns = {}
    }
  },
  notes = 'The local normal vector of the circle is `(0, 0, 1)`.',
  related = {
    'lovr.graphics.arc'
  }
}
