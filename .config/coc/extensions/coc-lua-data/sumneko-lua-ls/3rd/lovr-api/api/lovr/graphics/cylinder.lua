return {
  tag = 'graphicsPrimitives',
  summary = 'Draw a cylinder.',
  description = 'Draws a cylinder.',
  arguments = {
    material = {
      type = 'Material',
      description = 'The Material to apply to the cylinder.'
    },
    x = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the center of the cylinder.'
    },
    y = {
      type = 'number',
      default = '0',
      description = 'The y coordinate of the center of the cylinder.'
    },
    z = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the center of the cylinder.'
    },
    length = {
      type = 'number',
      default = '1',
      description = 'The length of the cylinder, in meters.'
    },
    angle = {
      type = 'number',
      default = '0',
      description = 'The rotation of the cylinder around its rotation axis, in radians.'
    },
    ax = {
      type = 'number',
      default = '0',
      description = 'The x coordinate of the cylinder\'s axis of rotation.'
    },
    ay = {
      type = 'number',
      default = '1',
      description = 'The y coordinate of the cylinder\'s axis of rotation.'
    },
    az = {
      type = 'number',
      default = '0',
      description = 'The z coordinate of the cylinder\'s axis of rotation.'
    },
    r1 = {
      type = 'number',
      default = '1',
      description = 'The radius of one end of the cylinder.'
    },
    r2 = {
      type = 'number',
      default = '1',
      description = 'The radius of the other end of the cylinder.'
    },
    capped = {
      type = 'boolean',
      default = 'true',
      description = 'Whether the top and bottom should be rendered.'
    },
    segments = {
      type = 'number',
      default = 'nil',
      description = [[
        The number of radial segments to use for the cylinder.  If nil, the segment count is
        automatically determined from the radii.
      ]]
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'x', 'y', 'z', 'length', 'angle', 'ax', 'ay', 'az', 'r1', 'r2', 'capped', 'segments' },
      returns = {}
    },
    {
      arguments = { 'material', 'x', 'y', 'z', 'length', 'angle', 'ax', 'ay', 'az', 'r1', 'r2', 'capped', 'segments' },
      returns = {}
    }
  },
  notes = [[
    Currently, cylinders don't have UVs.
  ]]
}
