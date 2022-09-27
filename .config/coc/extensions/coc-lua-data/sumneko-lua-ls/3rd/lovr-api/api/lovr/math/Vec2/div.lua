return {
  summary = 'Divides the vector by a vector or a number.',
  description = 'Divides the vector by a vector or a number.',
  arguments = {
    u = {
      type = 'Vec2',
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
    }
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
    'Vec2:sub',
    'Vec2:mul'
  }
}
