return {
  summary = 'Turn the matrix into an orthographic projection.',
  description = [[
    Sets this matrix to represent an orthographic projection, useful for 2D/isometric rendering.

    This can be used with `lovr.graphics.setProjection`, or it can be sent to a `Shader` for use in
    GLSL.
  ]],
  arguments = {
    {
      name = 'left',
      type = 'number',
      description = 'The left edge of the projection.'
    },
    {
      name = 'right',
      type = 'number',
      description = 'The right edge of the projection.'
    },
    {
      name = 'top',
      type = 'number',
      description = 'The top edge of the projection.'
    },
    {
      name = 'bottom',
      type = 'number',
      description = 'The bottom edge of the projection.'
    },
    {
      name = 'near',
      type = 'number',
      description = 'The position of the near clipping plane.'
    },
    {
      name = 'far',
      type = 'number',
      description = 'The position of the far clipping plane.'
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
    'Mat4:perspective',
    'Mat4:fov',
    'lovr.graphics.setProjection'
  }
}
