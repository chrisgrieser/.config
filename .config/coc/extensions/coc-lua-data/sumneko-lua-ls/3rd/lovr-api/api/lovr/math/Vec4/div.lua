return {
  summary = 'Divides the vector by a vector or a number.',
  description = 'Divides the vector by a vector or a number.',
  arguments = {
    u = {
      type = 'Vec4',
      description = 'The other vector to divide the components by.'
    },
    x = {
      type = 'number',
      description = 'A value to divide x component by.'
    },
    y = {
      type = 'number',
      default = 'x',
      description = 'A value to divide y component by.'
    },
    z = {
      type = 'number',
      default = 'x',
      description = 'A value to divide z component by.'
    },
    w = {
      type = 'number',
      default = 'x',
      description = 'A value to divide w component by.'
    }
  },
  returns = {
    v = {
      type = 'Vec4',
      description = 'The original vector.'
    }
  },
  variants = {
    {
      arguments = { 'u' },
      returns = { 'v' }
    },
    {
      arguments = { 'x', 'y', 'z', 'w' },
      returns = { 'v' }
    }
  },
  related = {
    'Vec4:add',
    'Vec4:sub',
    'Vec4:mul'
  }
}
