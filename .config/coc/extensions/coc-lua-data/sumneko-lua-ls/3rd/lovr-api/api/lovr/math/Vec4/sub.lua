return {
  summary = 'Subtract a vector or a number from the vector.',
  description = 'Subtracts a vector or a number from the vector.',
  arguments = {
    u = {
      type = 'Vec4',
      description = 'The other vector.'
    },
    x = {
      type = 'number',
      description = 'A value to subtract from x component.'
    },
    y = {
      type = 'number',
      default = 'x',
      description = 'A value to subtract from y component.'
    },
    z = {
      type = 'number',
      default = 'x',
      description = 'A value to subtract from z component.'
    },
    w = {
      type = 'number',
      default = 'x',
      description = 'A value to subtract from w component.'
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
    'Vec4:mul',
    'Vec4:div'
  }
}
