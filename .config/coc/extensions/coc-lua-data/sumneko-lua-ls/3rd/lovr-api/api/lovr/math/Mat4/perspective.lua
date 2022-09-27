return {
  summary = 'Turn the matrix into a perspective projection.',
  description = [[
    Sets this matrix to represent a perspective projection.

    This can be used with `lovr.graphics.setProjection`, or it can be sent to a `Shader` for use in
    GLSL.
  ]],
  arguments = {
    {
      name = 'near',
      type = 'number',
      description = 'The near plane.'
    },
    {
      name = 'far',
      type = 'number',
      description = 'The far plane.'
    },
    {
      name = 'fov',
      type = 'number',
      description = 'The vertical field of view (in radians).'
    },
    {
      name = 'aspect',
      type = 'number',
      description = 'The horizontal aspect ratio of the projection (width / height).'
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
    'Mat4:fov',
    'lovr.graphics.setProjection'
  }
}
