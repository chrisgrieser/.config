return {
  summary = 'Send a Texture to a Shader for writing.',
  description = [[
    Sends a Texture to a Shader for writing.  This is meant to be used with compute shaders and only
    works with uniforms declared as `image2D`, `imageCube`, `image2DArray`, and `image3D`.  The
    normal `Shader:send` function accepts Textures and should be used most of the time.
  ]],
  arguments = {
    name = {
      type = 'string',
      description = 'The name of the image uniform.'
    },
    index = {
      type = 'number',
      description = 'The array index to set.'
    },
    texture = {
      type = 'Texture',
      description = 'The Texture to assign.'
    },
    slice = {
      type = 'number',
      default = 'nil',
      description = 'The slice of a cube, array, or volume texture to use, or `nil` for all slices.'
    },
    mipmap = {
      type = 'number',
      default = '1',
      description = 'The mipmap of the texture to use.'
    },
    access = {
      type = 'UniformAccess',
      default = [['readwrite']],
      description = 'Whether the image will be read from, written to, or both.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'name', 'texture', 'slice', 'mipmap', 'access' },
      returns = {}
    },
    {
      arguments = { 'name', 'index', 'texture', 'slice', 'mipmap', 'access' },
      returns = {}
    }
  },
  related = {
    'Shader:send',
    'ShaderBlock:send',
    'ShaderBlock:getShaderCode',
    'UniformAccess',
    'ShaderBlock'
  }
}
