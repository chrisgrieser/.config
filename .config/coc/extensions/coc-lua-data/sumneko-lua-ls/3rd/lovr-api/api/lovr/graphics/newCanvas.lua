return {
  tag = 'graphicsObjects',
  summary = 'Create a new Canvas.',
  description = [[
    Creates a new Canvas.  You can specify Textures to attach to it, or just specify a width and
    height and attach textures later using `Canvas:setTexture`.

    Once created, you can render to the Canvas using `Canvas:renderTo`, or
    `lovr.graphics.setCanvas`.
  ]],
  arguments = {
    width = {
      type = 'number',
      description = 'The width of the canvas, in pixels.'
    },
    height = {
      type = 'number',
      description = 'The height of the canvas, in pixels.'
    },
    ['...'] = {
      type = 'Texture',
      description = 'One or more Textures to attach to the Canvas.'
    },
    attachments = {
      type = 'table',
      description = 'A table of textures, layers, and mipmaps (in any combination) to attach.'
    },
    flags = {
      type = 'table',
      default = '{}',
      description = 'Optional settings for the Canvas.',
      table = {
        {
          name = 'format',
          type = 'TextureFormat',
          default = [['rgba']],
          description = [[
            The format of a Texture to create and attach to this Canvas, or false if no Texture
            should be created.  This is ignored if Textures are already passed in.
          ]]
        },
        {
          name = 'depth',
          type = 'TextureFormat',
          default = [['d16']],
          description = [[
            A depth TextureFormat to use for the Canvas depth buffer, or false for no depth buffer.
            Note that this can also be a table with `format` and `readable` keys.
          ]]
        },
        {
          name = 'stereo',
          type = 'boolean',
          default = 'true',
          description = 'Whether the Canvas is stereo.'
        },
        {
          name = 'msaa',
          type = 'number',
          default = '0',
          description = 'The number of MSAA samples to use for antialiasing.'
        },
        {
          name = 'mipmaps',
          type = 'boolean',
          default = 'true',
          description = [[
            Whether the Canvas will automatically generate mipmaps for its attached textures.
          ]]
        }
      }
    }
  },
  returns = {
    canvas = {
      type = 'Canvas',
      description = 'The new Canvas.'
    }
  },
  variants = {
    {
      description = 'Create an empty Canvas with no Textures attached.',
      arguments = { 'width', 'height', 'flags' },
      returns = { 'canvas' }
    },
    {
      description = 'Create a Canvas with attached Textures.',
      arguments = { '...', 'flags' },
      returns = { 'canvas' }
    },
    {
      description = [[
        Create a Canvas with attached Textures, using specific layers and mipmap levels from each
        one.  Layers and mipmaps can be specified after each Texture as numbers, or a table of a
        Texture, layer, and mipmap can be used for each attachment.
      ]],
      arguments = { 'attachments', 'flags' },
      returns = { 'canvas' }
    }
  },
  notes = [[
    Textures created by this function will have `clamp` as their `WrapMode`.

    Stereo Canvases will either have their width doubled or use array textures for their
    attachments, depending on their implementation.
  ]],
  related = {
    'lovr.graphics.setCanvas',
    'lovr.graphics.getCanvas',
    'Canvas:renderTo'
  }
}
