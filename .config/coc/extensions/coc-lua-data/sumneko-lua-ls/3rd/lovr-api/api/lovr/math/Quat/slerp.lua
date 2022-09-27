return {
  summary = 'Moves this quaternion some amount towards another one.',
  description = [[
    Performs a spherical linear interpolation between this quaternion and another one, which can be
    used for smoothly animating between two rotations.

    The amount of interpolation is controlled by a parameter `t`.  A `t` value of zero leaves the
    original quaternion unchanged, whereas a `t` of one sets the original quaternion exactly equal
    to the target.  A value between `0` and `1` returns a rotation between the two based on the
    value.
  ]],
  arguments = {
    {
      name = 'r',
      type = 'Quat',
      description = 'The quaternion to slerp towards.'
    },
    {
      name = 't',
      type = 'number',
      description = 'The lerping parameter.'
    }
  },
  returns = {
    {
      name = 'q',
      type = 'Quat',
      description = 'The original quaternion, containing the new lerped values.'
    }
  },
  related = {
    'Vec3:lerp'
  }
}
