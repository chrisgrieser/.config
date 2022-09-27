return {
  summary = 'Create a new Rasterizer.',
  description = 'Creates a new Rasterizer from a TTF file.',
  arguments = {
    filename = {
      type = 'string',
      description = 'The filename of the font file to load.'
    },
    blob = {
      type = 'Blob',
      description = 'The Blob containing font data.'
    },
    size = {
      type = 'number',
      default = '32',
      description = [[
        The resolution to render the fonts at, in pixels.  Higher resolutions use more memory and
        processing power but may provide better quality results for some fonts/situations.
      ]]
    }
  },
  returns = {
    rasterizer = {
      type = 'Rasterizer',
      description = 'The new Rasterizer.'
    }
  },
  variants = {
    {
      description = 'Create a Rasterizer for the default font included with LÖVR (Varela Round).',
      arguments = { 'size' },
      returns = { 'rasterizer' }
    },
    {
      arguments = { 'filename', 'size' },
      returns = { 'rasterizer' }
    },
    {
      arguments = { 'blob', 'size' },
      returns = { 'rasterizer' }
    }
  }
}
