return {
  summary = 'Attach one or more Textures to the Canvas.',
  description = [[
    Attaches one or more Textures to the Canvas.  When rendering to the Canvas, everything will be
    drawn to all attached Textures.  You can attach different layers of an array, cubemap, or volume
    texture, and also attach different mipmap levels of Textures.
  ]],
  arguments = {
    {
      name = '...',
      type = '*',
      description = 'One or more Textures to attach to the Canvas.'
    }
  },
  returns = {},
  notes = [[
    There are some restrictions on how textures can be attached:

    - Up to 4 textures can be attached at once.
    - Textures must have the same dimensions and multisample settings as the Canvas.

    To specify layers and mipmaps to attach, specify them after the Texture.  You can also
    optionally wrap them in a table.
  ]],
  example = {
    description = 'Various ways to attach textures to a Canvas.',
    code = [[
      canvas:setTexture(textureA)
      canvas:setTexture(textureA, textureB) -- Attach two textures
      canvas:setTexture(textureA, layer, mipmap) -- Attach a specific layer and mipmap
      canvas:setTexture(textureA, layer, textureB, layer) -- Attach specific layers
      canvas:setTexture({ textureA, layer, mipmap }, textureB, { textureC, layer }) -- Tables
      canvas:setTexture({ { textureA, layer, mipmap }, textureB, { textureC, layer } })
    ]]
  }
}
