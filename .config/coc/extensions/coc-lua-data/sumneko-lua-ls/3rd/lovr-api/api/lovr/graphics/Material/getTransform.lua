return {
  summary = 'Get the transformation applied to texture coordinates.',
  description = 'Returns the transformation applied to texture coordinates of the Material.',
  arguments = {},
  returns = {
    {
      name = 'ox',
      type = 'number',
      description = 'The texture coordinate x offset.'
    },
    {
      name = 'oy',
      type = 'number',
      description = 'The texture coordinate y offset.'
    },
    {
      name = 'sx',
      type = 'number',
      description = 'The texture coordinate x scale.'
    },
    {
      name = 'sy',
      type = 'number',
      description = 'The texture coordinate y scale.'
    },
    {
      name = 'angle',
      type = 'number',
      description = 'The texture coordinate rotation, in radians.'
    }
  },
  notes = [[
    Although texture coordinates will automatically be transformed by the Material's transform, the
    material transform is exposed as the `mat3 lovrMaterialTransform` uniform variable in shaders,
    allowing it to be used for other purposes.
  ]]
}
