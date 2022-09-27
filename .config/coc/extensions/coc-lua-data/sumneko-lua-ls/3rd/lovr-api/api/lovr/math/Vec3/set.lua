return {
  summary = 'Set the components of the vector.',
  description = 'Sets the components of the vector, either from numbers or an existing vector.',
  arguments = {
    x = {
      type = 'number',
      default = '0',
      description = 'The new x value of the vector.'
    },
    y = {
      type = 'number',
      default = 'x',
      description = 'The new y value of the vector.'
    },
    z = {
      type = 'number',
      default = 'x',
      description = 'The new z value of the vector.'
    },
    u = {
      type = 'Vec3',
      description = 'The vector to copy the values from.'
    },
    m = {
      type = 'Mat4',
      description = 'The matrix to use the position of.'
    }
  },
  returns = {
    v = {
      type = 'Vec3',
      description = 'The input vector.'
    }
  },
  variants = {
    {
      arguments = { 'x', 'y', 'z' },
      returns = { 'v' }
    },
    {
      arguments = { 'u' },
      returns = { 'v' }
    },
    {
      arguments = { 'm' },
      returns = { 'v' }
    }
  },
  related = {
    'Vec3:unpack'
  }
}
