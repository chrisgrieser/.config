return {
  summary = 'Set a texture for the Material.',
  description = [[
    Sets a texture for a Material.  Several predefined `MaterialTexture`s are supported.  Any
    texture that is `nil` will use a single white pixel as a fallback.
  ]],
  arguments = {
    textureType = {
      type = 'MaterialTexture',
      default = [['diffuse']],
      description = 'The type of texture to set.'
    },
    texture = {
      type = 'Texture',
      description = 'The texture to apply, or `nil` to use the default.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'textureType', 'texture' },
      returns = {}
    },
    {
      arguments = { 'texture' },
      returns = {}
    }
  },
  related = {
    'MaterialTexture',
    'lovr.graphics.newTexture'
  }
}
