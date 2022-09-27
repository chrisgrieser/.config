return {
  summary = 'Subtract a vector or a number from the vector.',
  description = 'Subtracts a vector or a number from the vector.',
  arguments = {
    u = {
      type = 'Vec2',
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
  },
  returns = {
    v = {
      type = 'Vec2',
      description = 'The original vector.'
    }
  },
  variants = {
    {
      arguments = { 'u' },
      returns = { 'v' }
    },
    {
      arguments = { 'x', 'y' },
      returns = { 'v' }
    }
  },
  related = {
    'Vec2:add',
    'Vec2:mul',
    'Vec2:div'
  }
}
