return {
  summary = 'Get the distance to another vector.',
  description = 'Returns the distance to another vector.',
  arguments = {
    u = {
      name = 'u',
      type = 'Vec3',
      description = 'The vector to measure the distance to.'
    },
    x = {
      type = 'number',
      description = 'A value of x component to measure distance to.'
    },
    y = {
      type = 'number',
      description = 'A value of y component to measure distance to.'
    },
    z = {
      type = 'number',
      description = 'A value of z component to measure distance to.'
    }
  },
  returns = {
    distance = {
      type = 'number',
      description = 'The distance to `u`.'
    }
  },
  variants = {
    {
      arguments = { 'u' },
      returns = { 'distance' }
    },
    {
      arguments = { 'x', 'y', 'z' },
      returns = { 'distance' }
    }
  },
  related = {
    'Vec3:length'
  }
}
