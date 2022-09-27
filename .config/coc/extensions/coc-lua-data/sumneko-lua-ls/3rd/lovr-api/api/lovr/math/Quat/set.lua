return {
  summary = 'Set the components of the quaternion.',
  description = [[
    Sets the components of the quaternion.  There are lots of different ways to specify the new
    components, the summary is:

    - Four numbers can be used to specify an angle/axis rotation, similar to other LÖVR functions.
    - Four numbers plus the fifth `raw` flag can be used to set the raw values of the quaternion.
    - An existing quaternion can be passed in to copy its values.
    - A single direction vector can be specified to turn its direction (relative to the default
      forward direction of "negative z") into a rotation.
    - Two direction vectors can be specified to set the quaternion equal to the rotation between the
      two vectors.
    - A matrix can be passed in to extract the rotation of the matrix into a quaternion.
  ]],
  arguments = {
    angle = {
      default = '0',
      description = 'The angle to use for the rotation, in radians.'
    },
    ax = {
      type = 'number',
      default = '0',
      description = 'The x component of the axis of rotation.'
    },
    ay = {
      type = 'number',
      default = '0',
      description = 'The y component of the axis of rotation.'
    },
    az = {
      type = 'number',
      default = '0',
      description = 'The z component of the axis of rotation.'
    },
    raw = {
      type = 'boolean',
      default = 'false',
      description = 'Whether the components should be interpreted as raw `(x, y, z, w)` components.'
    },
    v = {
      type = 'vec3',
      description = 'A normalized direction vector.'
    },
    u = {
      type = 'vec3',
      description = 'Another normalized direction vector.'
    },
    r = {
      type = 'quat',
      description = 'An existing quaternion to copy the values from.'
    },
    m = {
      type = 'mat4',
      description = 'A matrix to use the rotation from.'
    }
  },
  returns = {
    q = {
      type = 'quat',
      description = 'The original quaternion.'
    }
  },
  variants = {
    {
      arguments = { 'angle', 'ax', 'ay', 'az', 'raw' },
      returns = { 'q' }
    },
    {
      arguments = { 'r' },
      returns = { 'q' }
    },
    {
      description = 'Sets the values from a direction vector.',
      arguments = { 'v' },
      returns = { 'q' }
    },
    {
      description = 'Sets the values to represent the rotation between two vectors.',
      arguments = { 'v', 'u' },
      returns = { 'q' }
    },
    {
      arguments = { 'm' },
      returns = { 'q' }
    },
    {
      description = 'Reset the quaternion to the identity (0, 0, 0, 1).',
      arguments = {},
      returns = { 'q' }
    }
  },
  related = {
    'Quat:unpack'
  }
}
