return {
  tag = 'sourceEffects',
  summary = 'Get the directivity of the Source.',
  description = [[
    Returns the directivity settings for the Source.

    The directivity is controlled by two parameters: the weight and the power.

    The weight is a number between 0 and 1 controlling the general "shape" of the sound emitted.
    0.0 results in a completely omnidirectional sound that can be heard from all directions.  1.0
    results in a full dipole shape that can be heard only from the front and back.  0.5 results in a
    cardioid shape that can only be heard from one direction.  Numbers in between will smoothly
    transition between these.

    The power is a number that controls how "focused" or sharp the shape is.  Lower power values can
    be heard from a wider set of angles.  It is an exponent, so it can get arbitrarily large.  Note
    that a power of zero will still result in an omnidirectional source, regardless of the weight.
  ]],
  arguments = {},
  returns = {
    {
      name = 'weight',
      type = 'number',
      description = 'The dipole weight.  0.0 is omnidirectional, 1.0 is a dipole, 0.5 is cardioid.'
    },
    {
      name = 'power',
      type = 'number',
      description = 'The dipole power, controlling how focused the directivity shape is.'
    }
  }
}
