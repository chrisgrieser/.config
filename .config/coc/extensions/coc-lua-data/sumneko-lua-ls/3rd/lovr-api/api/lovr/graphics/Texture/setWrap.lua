return {
  summary = 'Set the WrapMode for the Texture.',
  description = [[
    Sets the wrap mode of a texture.  The wrap mode controls how the texture is sampled when texture
    coordinates lie outside the usual 0 - 1 range.  The default for both directions is `repeat`.
  ]],
  arguments = {
    {
      name = 'horizontal',
      type = 'WrapMode',
      description = 'How the texture should wrap horizontally.'
    },
    {
      name = 'vertical',
      type = 'WrapMode',
      default = 'horizontal',
      description = 'How the texture should wrap vertically.'
    }
  },
  returns = {}
}
