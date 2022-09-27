return {
  summary = 'Add a vector or a number to the vector.',
  description = 'Adds a vector or a number to the vector.',
  arguments = {
    u = {
      type = 'Vec2',
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
    'Vec2:sub',
    'Vec2:mul',
    'Vec2:div'
  }
}
