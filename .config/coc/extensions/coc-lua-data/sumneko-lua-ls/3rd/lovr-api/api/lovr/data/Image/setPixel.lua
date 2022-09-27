return {
  summary = 'Set the value of a pixel of the Image.',
  description = 'Sets the value of a pixel of the Image.',
  arguments = {
    {
      name = 'x',
      type = 'number',
      description = 'The x coordinate of the pixel to set (0-indexed).'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y coordinate of the pixel to set (0-indexed).'
    },
    {
      name = 'r',
      type = 'number',
      description = 'The red component of the pixel, from 0.0 to 1.0.'
    },
    {
      name = 'g',
      type = 'number',
      description = 'The green component of the pixel, from 0.0 to 1.0.'
    },
    {
      name = 'b',
      type = 'number',
      description = 'The blue component of the pixel, from 0.0 to 1.0.'
    },
    {
      name = 'a',
      type = 'number',
      default = '1.0',
      description = 'The alpha component of the pixel, from 0.0 to 1.0.'
    }
  },
  returns = {},
  notes = [[
    The following texture formats are supported: `rgba`, `rgb`, `r32f`, `rg32f`, and `rgba32f`.
  ]],
  related = {
    'Image:getPixel',
    'Texture:replacePixels',
    'TextureFormat'
  }
}
