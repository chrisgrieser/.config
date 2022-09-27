return {
  summary = 'Create a model transform that targets from a position to target position.',
  description = [[
    Sets a model transform matrix that moves to `from` and orients model towards `to` point.

    This is used when rendered model should always point torwards a point of interest. The
    resulting Mat4 object can be used as model pose.

    The target() function produces same result as lookAt() after matrix inversion.
  ]],
  arguments = {
    {
      name = 'from',
      type = 'Vec3',
      description = 'The position of the viewer.'
    },
    {
      name = 'to',
      type = 'Vec3',
      description = 'The position of the target.'
    },
    {
      name = 'up',
      type = 'Vec3',
      default = 'Vec3(0, 1, 0)',
      description = 'The up vector of the viewer.'
    }
  },
  returns = {
    {
      name = 'm',
      type = 'Mat4',
      description = 'The original matrix.'
    }
  },
  related = {
    'Mat4:lookAt',
    'Quat:direction'
  }
}
