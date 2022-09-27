return {
  summary = 'Subtract a vector or a number from the vector.',
  description = 'Subtracts a vector or a number from the vector.',
  arguments = {
    u = {
      type = 'Vec3',
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
    }
  },
  returns = {
    v = {
      type = 'Vec3',
      description = 'The original vector.'
    }
  },
  variants = {
    {
      arguments = { 'u' },
      returns = { 'v' }
    },
    {
      arguments = { 'x', 'y', 'z' },
      returns = { 'v' }
    }
  },
  related = {
    'Vec3:add',
    'Vec3:mul',
    'Vec3:div'
  }
}
