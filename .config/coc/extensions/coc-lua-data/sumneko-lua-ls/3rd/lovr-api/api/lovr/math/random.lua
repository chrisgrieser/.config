return {
  tag = 'random',
  summary = 'Get a random number.',
  description = [[
    Returns a uniformly distributed pseudo-random number.  This function has improved randomness
    over Lua's `math.random` and also guarantees that the sequence of random numbers will be the
    same on all platforms (given the same seed).
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
  notes = 'You can set the random seed using `lovr.math.setRandomSeed`.',
  related = {
    'lovr.math.randomNormal',
    'RandomGenerator',
    'lovr.math.noise'
  }
}
