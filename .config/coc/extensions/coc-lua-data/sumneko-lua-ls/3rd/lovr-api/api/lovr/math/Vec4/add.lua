return {
  summary = 'Add a vector or a number to the vector.',
  description = 'Adds a vector or a number to the vector.',
  arguments = {
    u = {
      type = 'Vec4',
      description = 'The other vector.'
    },
    x = {
      type = 'number',
      description = 'A value to add to x component.'
    },
    y = {
      type = 'number',
      default = 'x',
      description = 'A value to add to y component.'
    },
    z = {
      type = 'number',
      default = 'x',
      description = 'A value to add to z component.'
    },
    w = {
      type = 'number',
      default = 'x',
      description = 'A value to add to w component.'
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
    'Vec4:sub',
    'Vec4:mul',
    'Vec4:div'
  }
}
