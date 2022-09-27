return {
  summary = 'Copy pixels from another Image to this one.',
  description = 'Copies a rectangle of pixels from one Image to this one.',
  arguments = {
    {
      name = 'source',
      type = 'Image',
      description = 'The Image to copy pixels from.'
    },
    {
      name = 'x',
      type = 'number',
      default = '0',
      description = 'The x coordinate to paste to (0-indexed).',
    },
    {
      name = 'y',
      type = 'number',
      default = '0',
      description = 'The y coordinate to paste to (0-indexed).',
    },
    {
      name = 'fromX',
      type = 'number',
      default = '0',
      description = 'The x coordinate in the source to paste from (0-indexed).',
    },
    {
      name = 'fromY',
      type = 'number',
      default = '0',
      description = 'The y coordinate in the source to paste from (0-indexed).',
    },
    {
      name = 'width',
      type = 'number',
      default = 'source:getWidth()',
      description = 'The width of the region to copy.'
    },
    {
      name = 'height',
      type = 'number',
      default = 'source:getHeight()',
      description = 'The height of the region to copy.'
    }
  },
  returns = {},
  notes = [[
    The two Images must have the same pixel format.

    Compressed images cannot be copied.

    The rectangle cannot go outside the dimensions of the source or destination textures.
  ]],
  related = {
    'Texture:replacePixels',
    'Image:getPixel',
    'Image:setPixel'
  }
}
