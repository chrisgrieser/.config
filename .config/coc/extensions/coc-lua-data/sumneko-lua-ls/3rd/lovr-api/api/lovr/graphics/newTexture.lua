return {
  tag = 'graphicsObjects',
  summary = 'Create a new Texture.',
  description = 'Creates a new Texture from an image file.',
  arguments = {
    width = {
      type = 'number',
      description = 'The width of the Texture.'
    },
    height = {
      type = 'number',
      description = 'The height of the Texture.'
    },
    depth = {
      type = 'number',
      description = 'The depth of the Texture.'
    },
    filename = {
      type = 'string',
      description = 'The filename of the image to load.'
    },
    blob = {
      type = 'Blob',
      description = 'The Blob containing encoded image data used to create the Texture.'
    },
    image = {
      type = 'Image',
      description = 'The Image to create the Texture from.'
    },
    images = {
      type = 'table',
      description = 'A table of image filenames to load.'
    },
    flags = {
      type = 'table',
      default = '{}',
      description = 'Optional settings for the texture.',
      table = {
        {
          name = 'linear',
          type = 'boolean',
          default = 'false',
          description = 'Whether the texture is in linear color space instead of the usual sRGB.'
        },
        {
          name = 'mipmaps',
          type = 'boolean',
          default = 'true',
          description = 'Whether mipmaps will be generated for the texture.'
        },
        {
          name = 'type',
          type = 'TextureType',
          default = 'nil',
          description = [[
            The type of Texture to load the images into.  If nil, the type will be `2d` for a
            single image, `array` for a table of images with numeric keys, or `cube` for a table
            of images with string keys.
          ]]
        },
        {
          name = 'format',
          type = 'TextureFormat',
          default = [['rgba']],
          description = 'The format used for the Texture (when creating a blank texture).'
        },
        {
          name = 'msaa',
          type = 'number',
          default = '0',
          description = 'The antialiasing level to use (when attaching the Texture to a Canvas).'
        }
      }
    }
  },
  returns = {
    texture = {
      name = 'texture',
      type = 'Texture',
      description = 'The new Texture.'
    }
  },
  variants = {
    {
      arguments = { 'filename', 'flags' },
      returns = { 'texture' }
    },
    {
      description = [[
        Create a Texture from a table of filenames, Blobs, or Images.  For cube textures, the
        individual faces can be specified using the string keys "right", "left", "top", "bottom",
        "back", "front".
      ]],
      arguments = { 'images', 'flags' },
      returns = { 'texture' }
    },
    {
      description = [[
        Creates a blank Texture with specified dimensions.  This saves memory if you're planning on
        rendering to the Texture using a Canvas or a compute shader, but the contents of the Texture
        will be initialized to random data.
      ]],
      arguments = { 'width', 'height', 'depth', 'flags' },
      returns = { 'texture' }
    },
    {
      description = 'Create a texture from a single Blob.',
      arguments = { 'blob', 'flags' },
      returns = { 'texture' }
    },
    {
      description = 'Create a texture from a single Image.',
      arguments = { 'image', 'flags' },
      returns = { 'texture' }
    }
  },
  notes = [[
    The "linear" flag should be set to true for textures that don't contain color information, such
    as normal maps.

    Right now the supported image file formats are png, jpg, hdr, dds (DXT1, DXT3, DXT5), ktx, and
    astc.
  ]]
}
