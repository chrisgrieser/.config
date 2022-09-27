return {
  summary = 'Set a projection using raw FoV angles.',
  description = [[
    Sets a projection matrix using raw projection angles and clipping planes.

    This can be used for asymmetric or oblique projections.
  ]],
  arguments = {
    {
      name = 'left',
      type = 'number',
      description = 'The left half-angle of the projection, in radians.'
    },
    {
      name = 'right',
      type = 'number',
      description = 'The right half-angle of the projection, in radians.'
    },
    {
      name = 'up',
      type = 'number',
      description = 'The top half-angle of the projection, in radians.'
    },
    {
      name = 'down',
      type = 'number',
      description = 'The bottom half-angle of the projection, in radians.'
    },
    {
      name = 'near',
      type = 'number',
      description = 'The near plane of the projection.'
    },
    {
      name = 'far',
      type = 'number',
      description = 'The far plane of the projection.'
    }
  },
  returns = {
    {
      name = 'm',
      type = 'Mat4',
      description = 'The original matrix.'
    }
  },
  related = {
    'Mat4:orthographic',
    'Mat4:perspective',
    'lovr.graphics.setProjection'
  }
}
