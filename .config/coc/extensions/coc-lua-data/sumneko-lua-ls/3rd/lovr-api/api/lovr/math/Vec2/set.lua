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
    u = {
      type = 'Vec2',
      description = 'The vector to copy the values from.'
    }
  },
  returns = {
    v = {
      type = 'Vec2',
      description = 'The input vector.'
    }
  },
  variants = {
    {
      arguments = { 'x', 'y' },
      returns = { 'v' }
    },
    {
      arguments = { 'u' },
      returns = { 'v' }
    }
  },
  related = {
    'Vec2:unpack'
  }
}
