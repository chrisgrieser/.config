return {
  summary = 'Scale the matrix.',
  description = 'Scales the matrix.',
  arguments = {
    scale = {
      type = 'Vec3',
      description = 'The 3D scale to apply.'
    },
    sx = {
      type = 'number',
      description = 'The x component of the scale to apply.'
    },
    sy = {
      type = 'number',
      default = 'sx',
      description = 'The y component of the scale to apply.'
    },
    sz = {
      type = 'number',
      default = 'sx',
      description = 'The z component of the scale to apply.'
    }
  },
  returns = {
    m = {
      type = 'Mat4',
      description = 'The original matrix.'
    }
  },
  variants = {
    {
      arguments = { 'scale' },
      returns = { 'm' }
    },
    {
      arguments = { 'sx', 'sy', 'sz' },
      returns = { 'm' }
    }
  },
  related = {
    'Mat4:translate',
    'Mat4:rotate',
    'Mat4:identity'
  }
}
