return {
  summary = 'Get the individual components of the matrix.',
  description = [[
    Returns the components of matrix, either as 10 separated numbers representing the position,
    scale, and rotation, or as 16 raw numbers representing the individual components of the matrix
    in column-major order.
  ]],
  arguments = {
    {
      name = 'raw',
      type = 'boolean',
      description = 'Whether to return the 16 raw components.'
    }
  },
  returns = {
    {
      name = '...',
      type = 'number',
      description = 'The requested components of the matrix.'
    }
  },
  related = {
    'Mat4:set'
  }
}
