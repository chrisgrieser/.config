return {
  summary = 'Multiply a matrix with another matrix or a vector.',
  description = [[
    Multiplies this matrix by another value.  Multiplying by a matrix combines their two transforms
    together.  Multiplying by a vector applies the transformation from the matrix to the vector and
    returns the vector.
  ]],
  arguments = {
    n = {
      type = 'Mat4',
      description = 'The matrix.'
    },
    v3 = {
      type = 'Vec3',
      description = 'A 3D vector, treated as a point.'
    },
    v4 = {
      type = 'Vec4',
      description = 'A 4D vector.'
    }
  },
  returns = {
    m = {
      type = 'Mat4',
      description = 'The original matrix, containing the result.'
    },
    v3 = {
      type = 'Vec3',
      description = 'The transformed vector.'
    },
    v4 = {
      type = 'Vec4',
      description = 'The transformed vector.'
    }
  },
  variants = {
    {
      arguments = { 'n' },
      returns = { 'm' }
    },
    {
      arguments = { 'v3' },
      returns = { 'v3' }
    },
    {
      arguments = { 'v4' },
      returns = { 'v4' }
    }
  },
  notes = [[
    When multiplying by a vec4, the vector is treated as either a point if its w component is 1, or
    a direction vector if the w is 0 (the matrix translation won't be applied).
  ]],
  related = {
    'Mat4:translate',
    'Mat4:rotate',
    'Mat4:scale'
  }
}
