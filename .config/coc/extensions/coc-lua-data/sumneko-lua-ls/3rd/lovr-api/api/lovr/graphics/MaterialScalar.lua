return {
  summary = 'Different material parameters.',
  description = 'The different types of float parameters `Material`s can hold.',
  values = {
    {
      name = 'metalness',
      description = 'The constant metalness factor.'
    },
    {
      name = 'roughness',
      description = 'The constant roughness factor.'
    }
  },
  related = {
    'Material:getScalar',
    'Material:setScalar',
    'MaterialColor',
    'MaterialTexture',
    'Material'
  }
}
