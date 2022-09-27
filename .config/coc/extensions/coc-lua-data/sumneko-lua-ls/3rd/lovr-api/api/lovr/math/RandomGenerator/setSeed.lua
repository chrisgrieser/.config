return {
  summary = 'Reinitialize the RandomGenerator with a new seed.',
  description = [[
    Seed the RandomGenerator with a new seed.  Each seed will cause the RandomGenerator to produce a
    unique sequence of random numbers.
  ]],
  arguments = {
    seed = {
      type = 'number',
      description = 'The random seed.'
    },
    low = {
      type = 'number',
      description = 'The lower 32 bits of the seed.'
    },
    high = {
      type = 'number',
      description = 'The upper 32 bits of the seed.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'seed' },
      returns = {}
    },
    {
      arguments = { 'low', 'high' },
      returns = {}
    }
  },
  notes = [[
    For precise 64 bit seeds, you should specify the lower and upper 32 bits of the seed separately.
    Otherwise, seeds larger than 2^53 will start to lose precision.
  ]]
}
