return {
  summary = 'Different storage formats for pixels in Textures.',
  description = [[
    Textures can store their pixels in different formats.  The set of color channels and the number
    of bits stored for each channel can differ, allowing Textures to optimize their storage for
    certain kinds of image formats or rendering techniques.
  ]],
  values = {
    {
      name = 'rgb',
      description = 'Each pixel is 24 bits, or 8 bits for each channel.'
    },
    {
      name = 'rgba',
      description = 'Each pixel is 32 bits, or 8 bits for each channel (including alpha).'
    },
    {
      name = 'rgba4',
      description = 'An rgba format where the colors occupy 4 bits instead of the usual 8.'
    },
    {
      name = 'rgba16f',
      description = 'Each pixel is 64 bits. Each channel is a 16 bit floating point number.'
    },
    {
      name = 'rgba32f',
      description = 'Each pixel is 128 bits. Each channel is a 32 bit floating point number.'
    },
    {
      name = 'r16f',
      description = 'A 16-bit floating point format with a single color channel.'
    },
    {
      name = 'r32f',
      description = 'A 32-bit floating point format with a single color channel.'
    },
    {
      name = 'rg16f',
      description = 'A 16-bit floating point format with two color channels.'
    },
    {
      name = 'rg32f',
      description = 'A 32-bit floating point format with two color channels.'
    },
    {
      name = 'rgb5a1',
      description = 'A 16 bit format with 5-bit color channels and a single alpha bit.'
    },
    {
      name = 'rgb10a2',
      description = 'A 32 bit format with 10-bit color channels and two alpha bits.'
    },
    {
      name = 'rg11b10f',
      description = 'Each pixel is 32 bits, and packs three color channels into 10 or 11 bits each.'
    },
    {
      name = 'd16',
      description = 'A 16 bit depth buffer.'
    },
    {
      name = 'd32f',
      description = 'A 32 bit floating point depth buffer.'
    },
    {
      name = 'd24s8',
      description = 'A depth buffer with 24 bits for depth and 8 bits for stencil.'
    }
  }
}
