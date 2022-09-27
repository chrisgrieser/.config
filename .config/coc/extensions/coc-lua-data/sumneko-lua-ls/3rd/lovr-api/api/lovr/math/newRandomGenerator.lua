return {
  tag = 'random',
  summary = 'Create a new RandomGenerator.',
  description = [[
    Creates a new `RandomGenerator`, which can be used to generate random numbers. If you just want
    some random numbers, you can use `lovr.math.random`. Individual RandomGenerator objects are
    useful if you need more control over the random sequence used or need a random generator
    isolated from other instances.
  ]],
  arguments = {
    seed = {
      type = 'number',
      description = 'The initial seed for the RandomGenerator.'
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
  returns = {
    randomGenerator = {
      type = 'RandomGenerator',
      description = 'The new RandomGenerator.'
    }
  },
  variants = {
    {
      description = 'Create a RandomGenerator with a default seed.',
      arguments = {},
      returns = { 'randomGenerator' }
    },
    {
      arguments = { 'seed' },
      returns = { 'randomGenerator' }
    },
    {
      description = [[
        This variant allows creation of random generators with precise 64-bit seed values, since
        Lua's number format loses precision with really big numbers.
      ]],
      arguments = { 'low', 'high' },
      returns = { 'randomGenerator' }
    }
  }
}
