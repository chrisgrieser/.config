return {
  tag = 'random',
  summary = 'Generate perlin noise.',
  description = [[
    Returns a 1D, 2D, 3D, or 4D perlin noise value.  The number will be between 0 and 1, and it will
    always be 0.5 when the inputs are integers.
  ]],
  arguments = {
    x = {
      type = 'number',
      description = 'The x coordinate of the input.'
    },
    y = {
      type = 'number',
      description = 'The y coordinate of the input.'
    },
    z = {
      type = 'number',
      description = 'The z coordinate of the input.'
    },
    w = {
      type = 'number',
      description = 'The w coordinate of the input.'
    }
  },
  returns = {
    noise = {
      type = 'number',
      description = 'The noise value, between 0 and 1.'
    }
  },
  variants = {
    {
      arguments = { 'x' },
      returns = { 'noise' }
    },
    {
      arguments = { 'x', 'y' },
      returns = { 'noise' }
    },
    {
      arguments = { 'x', 'y', 'z' },
      returns = { 'noise' }
    },
    {
      arguments = { 'x', 'y', 'z', 'w' },
      returns = { 'noise' }
    }
  },
  related = {
    'lovr.math.random'
  }
}
