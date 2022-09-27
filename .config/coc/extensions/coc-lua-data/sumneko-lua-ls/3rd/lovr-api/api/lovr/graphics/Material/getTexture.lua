return {
  summary = 'Get a texture for the Material.',
  description = [[
    Returns a texture for a Material.  Several predefined `MaterialTexture`s are supported.  Any
    texture that is `nil` will use a single white pixel as a fallback.
  ]],
  arguments = {
    {
      name = 'textureType',
      type = 'MaterialTexture',
      default = [['diffuse']],
      description = 'The type of texture to get.'
    }
  },
  returns = {
    {
      name = 'texture',
      type = 'Texture',
      description = 'The texture that is set, or `nil` if no texture is set.'
    }
  },
  related = {
    'MaterialTexture'
  }
}
