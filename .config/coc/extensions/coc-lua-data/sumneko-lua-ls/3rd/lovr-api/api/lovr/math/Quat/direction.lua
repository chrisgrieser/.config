return {
  summary = 'Get the direction of the quaternion.',
  description = [[
    Creates a new temporary vec3 facing the forward direction, rotates it by this quaternion, and
    returns the vector.
  ]],
  arguments = {},
  returns = {
    {
      name = 'v',
      type = 'Vec3',
      description = 'The direction vector.'
    }
  },
  related = {
    'Mat4:lookAt'
  }
}
