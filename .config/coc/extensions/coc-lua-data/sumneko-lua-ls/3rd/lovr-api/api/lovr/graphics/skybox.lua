return {
  tag = 'graphicsPrimitives',
  summary = 'Render a skybox.',
  description = [[
    Render a skybox from a texture.  Two common kinds of skybox textures are supported: A 2D
    equirectangular texture with a spherical coordinates can be used, or a "cubemap" texture created
    from 6 images.
  ]],
  arguments = {
    {
      name = 'texture',
      type = 'Texture',
      description = 'The texture to use.'
    }
  },
  returns = {},
  example = [[
    function lovr.load()
      skybox = lovr.graphics.newTexture({
        left = 'left.png',
        right = 'right.png',
        top = 'up.png',
        bottom = 'down.png',
        back = 'back.png',
        front = 'front.png'
      })

      -- or skybox = lovr.graphics.newTexture('equirectangular.png')
    end

    function lovr.draw()
      lovr.graphics.skybox(skybox)
    end
  ]]
}
