return {
  summary = 'Get a random number.',
  description = [[
    Returns the next uniformly distributed pseudo-random number from the RandomGenerator's sequence.
  ]],
  arguments = {
    low = {
      type = 'number',
      description = 'The minimum number to generate.'
    },
    high = {
      type = 'number',
      description = 'The maximum number to generate.'
    }
  },
  returns = {
    x = {
      type = 'number',
      description = 'A pseudo-random number.'
    }
  },
  variants = {
    {
      description = 'Generate a pseudo-random floating point number in the range `[0,1)`',
      arguments = {},
      returns = { 'x' }
    },
    {
      description = 'Generate a pseudo-random integer in the range `[1,high]`',
      arguments = { 'high' },
      returns = { 'x' }
    },
    {
      description = 'Generate a pseudo-random integer in the range `[low,high]`',
      arguments = { 'low', 'high' },
      returns = { 'x' }
    }
  },
  related = {
    'lovr.math.random',
    'RandomGenerator:randomNormal'
  }
}
