return {
  summary = 'Create a new Image.',
  description = [[
    Creates a new Image.  Image data can be loaded and decoded from an image file, or a raw block of
    pixels with a specified width, height, and format can be created.
  ]],
  arguments = {
    width = {
      type = 'number',
      description = 'The width of the texture.'
    },
    height = {
      type = 'number',
      description = 'The height of the texture.'
    },
    format = {
      type = 'TextureFormat',
      default = 'rgba',
      description = 'The format of the texture\'s pixels.'
    },
    filename = {
      type = 'string',
      description = 'The filename of the image to load.'
    },
    blob = {
      type = 'Blob',
      description = 'The Blob containing image data to decode.'
    },
    data = {
      type = 'Blob',
      default = 'nil',
      description = 'Raw pixel values to use as the contents.  If `nil`, the data will all be zero.'
    },
    source = {
      type = 'Image',
      description = 'The Image to clone.'
    },
    flip = {
      type = 'boolean',
      default = 'true',
      description = [[
        Whether to vertically flip the image on load.  This should be true for normal textures, and
        false for textures that are going to be used in a cubemap.
      ]]
    }
  },
  returns = {
    image = {
      type = 'Image',
      description = 'The new Image.'
    }
  },
  variants = {
    {
      description = 'Load image data from a file.',
      arguments = { 'filename', 'flip' },
      returns = { 'image' }
    },
    {
      description = 'Create an Image with a given size and pixel format.',
      arguments = { 'width', 'height', 'format', 'data' },
      returns = { 'image' }
    },
    {
      description = 'Clone an existing Image.',
      arguments = { 'source' },
      returns = { 'image' }
    },
    {
      description = 'Decode image data from a Blob.',
      arguments = { 'blob', 'flip' },
      returns = { 'image' }
    }
  },
  notes = [[
    The supported image file formats are png, jpg, hdr, dds (DXT1, DXT3, DXT5), ktx, and astc.

    Only 2D textures are supported for DXT/ASTC.

    Currently textures loaded as KTX need to be in DXT/ASTC formats.
  ]]
}
