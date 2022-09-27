return {
  tag = 'graphicsPrimitives',
  summary = 'Draw a box.',
  description = [[
    Draws a box.  This is similar to `lovr.graphics.cube` except you can have different values for
    the width, height, and depth of the box.
  ]],
  arguments = {
    material = {
      type = 'Material',
      description = 'The Material to apply to the box.'
    },
    mode = {
      type = 'DrawStyle',
      description = 'How to draw the box.'
    },
    transform = {
      type = 'mat4',
      description = 'The transform of the box.'
    },
    x = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the center of the box.'
    },
    y = {
      type = 'number',
      default = '0',
      description = 'The y coordinate of the center of the box.'
    },
    z = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the center of the box.'
    },
    width = {
      type = 'number',
      default = '1',
      description = 'The width of the box, in meters.'
    },
    height = {
      type = 'number',
      default = '1',
      description = 'The height of the box, in meters.'
    },
    depth = {
      type = 'number',
      default = '1',
      description = 'The depth of the box, in meters.'
    },
    angle = {
      type = 'number',
      default = '0',
      description = 'The rotation of the box around its rotation axis, in radians.'
    },
    ax = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the axis of rotation.'
    },
    ay = {
      type = 'number',
      default = '1',
      description = 'The y coordinate of the axis of rotation.'
    },
    az = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the axis of rotation.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'mode', 'x', 'y', 'z', 'width', 'height', 'depth', 'angle', 'ax', 'ay', 'az' },
      returns = {}
    },
    {
      arguments = { 'material', 'x', 'y', 'z', 'width', 'height', 'depth', 'angle', 'ax', 'ay', 'az' },
      returns = {}
    },
    {
      arguments = { 'mode', 'transform' },
      returns = {}
    },
    {
      arguments = { 'material', 'transform' },
      returns = {}
    }
  }
}
