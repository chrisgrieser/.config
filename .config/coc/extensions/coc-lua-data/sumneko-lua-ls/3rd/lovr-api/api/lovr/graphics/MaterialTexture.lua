return {
  summary = 'Different material texture parameters.',
  description = 'The different types of texture parameters `Material`s can hold.',
  values = {
    {
      name = 'diffuse',
      description = 'The diffuse texture.'
    },
    {
      name = 'emissive',
      description = 'The emissive texture.'
    },
    {
      name = 'metalness',
      description = 'The metalness texture.'
    },
    {
      name = 'roughness',
      description = 'The roughness texture.'
    },
    {
      name = 'occlusion',
      description = 'The ambient occlusion texture.'
    },
    {
      name = 'normal',
      description = 'The normal map.'
    },
    {
      name = 'environment',
      description = 'The environment map, should be specified as a cubemap texture.'
    }
  },
  related = {
    'Material:getTexture',
    'Material:setTexture',
    'MaterialColor',
    'MaterialScalar',
    'Material'
  }
}
