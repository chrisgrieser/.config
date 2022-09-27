return {
  tag = 'random',
  summary = 'Get a random number from a normal distribution.',
  description = [[
    Returns a pseudo-random number from a normal distribution (a bell curve).  You can control the
    center of the bell curve (the mean value) and the overall width (sigma, or standard deviation).
  ]],
  arguments = {
    {
      name = 'sigma',
      type = 'number',
      default = '1',
      description = [[
        The standard deviation of the distribution.  This can be thought of how "wide" the range of
        numbers is or how much variability there is.
      ]]
    },
    {
      name = 'mu',
      type = 'number',
      default = '0',
      description = 'The average value returned.'
    }
  },
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'A normally distributed pseudo-random number.'
    }
  },
  related = {
    'lovr.math.random',
    'RandomGenerator'
  }
}
