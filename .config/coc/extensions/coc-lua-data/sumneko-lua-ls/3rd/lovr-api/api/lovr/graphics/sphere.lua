return {
  tag = 'graphicsPrimitives',
  summary = 'Draw a sphere.',
  description = 'Draws a sphere.',
  arguments = {
    material = {
      type = 'Material',
      description = 'The Material to apply to the sphere.'
    },
    x = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the center of the sphere.'
    },
    y = {
      type = 'number',
      default = '0',
      description = 'The y coordinate of the center of the sphere.'
    },
    z = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the center of the sphere.'
    },
    radius = {
      type = 'number',
      default = '1',
      description = 'The radius of the sphere, in meters.'
    },
    angle = {
      type = 'number',
      default = '0',
      description = 'The rotation of the sphere around its rotation axis, in radians.'
    },
    ax = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the sphere\'s axis of rotation.'
    },
    ay = {
      type = 'number',
      default = '1',
      description = 'The y coordinate of the sphere\'s axis of rotation.'
    },
    az = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the sphere\'s axis of rotation.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'x', 'y', 'z', 'radius', 'angle', 'ax', 'ay', 'az' },
      returns = {}
    },
    {
      arguments = { 'material', 'x', 'y', 'z', 'radius', 'angle', 'ax', 'ay', 'az' },
      returns = {}
    }
  }
}
