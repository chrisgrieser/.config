return {
  summary = 'Get the dot product with another vector.',
  description = 'Returns the dot product between this vector and another one.',
  arguments = {
    u = {
      type = 'Vec2',
      description = 'The vector to compute the dot product with.'
    },
    x = {
      type = 'number',
      description = 'A value of x component to compute the dot product with.'
    },
    y = {
      type = 'number',
      description = 'A value of y component to compute the dot product with.'
    }
  },
  returns = {
    dot = {
      type = 'number',
      description = 'The dot product between `v` and `u`.'
    }
  },
  variants = {
    {
      arguments = { 'u' },
      returns = { 'dot' }
    },
    {
      arguments = { 'x', 'y' },
      returns = { 'dot' }
    }
  },
  notes = [[
    This is computed as:

        dot = v.x * u.x + v.y * u.y

    The vectors are not normalized before computing the dot product.
  ]]
}
