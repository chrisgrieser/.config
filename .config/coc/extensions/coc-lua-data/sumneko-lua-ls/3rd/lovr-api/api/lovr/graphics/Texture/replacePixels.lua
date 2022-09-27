return {
  summary = 'Replace pixels in the Texture using an Image object.',
  description = 'Replaces pixels in the Texture, sourcing from an `Image` object.',
  arguments = {
    {
      name = 'image',
      type = 'Image',
      description = [[
        The Image containing the pixels to use.  Currently, the Image needs to have the same
        dimensions as the source Texture.
      ]]
    },
    {
      name = 'x',
      type = 'number',
      default = '0',
      description = 'The x offset to replace at.'
    },
    {
      name = 'y',
      type = 'number',
      default = '0',
      description = 'The y offset to replace at.'
    },
    {
      name = 'slice',
      type = 'number',
      default = '1',
      description = 'The slice to replace.  Not applicable for 2D textures.'
    },
    {
      name = 'mipmap',
      type = 'number',
      default = '1',
      description = 'The mipmap to replace.'
    }
  },
  returns = {},
  related = {
    'Image:setPixel',
    'Image'
  }
}
