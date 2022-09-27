return {
  tag = 'graphicsPrimitives',
  summary = 'Draw a cube.',
  description = 'Draws a cube.',
  arguments = {
    material = {
      type = 'Material',
      description = 'The Material to apply to the cube faces.'
    },
    mode = {
      type = 'DrawStyle',
      description = 'How to draw the cube.'
    },
    transform = {
      type = 'mat4',
      description = 'The cube\'s transform.'
    },
    x = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the center of the cube.'
    },
    y = {
      type = 'number',
      default = '0',
      description = 'The y coordinate of the center of the cube.'
    },
    z = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the center of the cube.'
    },
    size = {
      type = 'number',
      default = '1',
      description = 'The size of the cube, in meters.'
    },
    angle = {
      type = 'number',
      default = '0',
      description = 'The rotation of the cube around its rotation axis, in radians.'
    },
    ax = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the cube\'s axis of rotation.'
    },
    ay = {
      type = 'number',
      default = '1',
      description = 'The y coordinate of the cube\'s axis of rotation.'
    },
    az = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the cube\'s axis of rotation.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'mode', 'x', 'y', 'z', 'size', 'angle', 'ax', 'ay', 'az' },
      returns = {}
    },
    {
      arguments = { 'material', 'x', 'y', 'z', 'size', 'angle', 'ax', 'ay', 'az' },
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
