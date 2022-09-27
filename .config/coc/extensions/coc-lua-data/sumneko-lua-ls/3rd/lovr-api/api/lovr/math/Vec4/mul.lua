return {
  summary = 'Multiply the vector by a vector or a number.',
  description = 'Multiplies the vector by a vector or a number.',
  arguments = {
    u = {
      type = 'Vec4',
      description = 'The other vector to multiply the components by.'
    },
    x = {
      type = 'number',
      description = 'A value to multiply x component by.'
    },
    y = {
      type = 'number',
      default = 'x',
      description = 'A value to multiply y component by.'
    },
    z = {
      type = 'number',
      default = 'x',
      description = 'A value to multiply z component by.'
    },
    w = {
      type = 'number',
      default = 'x',
      description = 'A value to multiply w component by.'
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
    'Vec4:div'
  }
}
