return {
  tag = 'random',
  summary = 'Set the random seed.',
  description = [[
    Seed the random generator with a new seed.  Each seed will cause `lovr.math.random` and
    `lovr.math.randomNormal` to produce a unique sequence of random numbers.  This is done once
    automatically at startup by `lovr.run`.
  ]],
  arguments = {
    {
      name = 'seed',
      type = 'number',
      description = 'The new seed.'
    }
  },
  returns = {}
}
