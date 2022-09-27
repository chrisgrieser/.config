function lovr.load()
  model = lovr.graphics.newModel('helmet/DamagedHelmet.glb')

  shader = lovr.graphics.newShader('standard', {
    flags = {
      normalMap = false,
      indirectLighting = true,
      occlusion = true,
      emissive = true,
      skipTonemap = false
    }
  })

  skybox = lovr.graphics.newTexture({
    left = 'env/nx.png',
    right = 'env/px.png',
    top = 'env/py.png',
    bottom = 'env/ny.png',
    back = 'env/pz.png',
    front = 'env/nz.png'
  }, { linear = true })

  environmentMap = lovr.graphics.newTexture(256, 256, { type = 'cube' })
  for mipmap = 1, environmentMap:getMipmapCount() do
    for face, dir in ipairs({ 'px', 'nx', 'py', 'ny', 'pz', 'nz' }) do
      local filename = ('env/m%d_%s.png'):format(mipmap - 1, dir)
      local image = lovr.data.newImage(filename, false)
      environmentMap:replacePixels(image, 0, 0, face, mipmap)
    end
  end

  shader:send('lovrLightDirection', { -1, -1, -1 })
  shader:send('lovrLightColor', { .9, .9, .8, 1.0 })
  shader:send('lovrExposure', 2)
  shader:send('lovrSphericalHarmonics', require('env/sphericalHarmonics'))
  shader:send('lovrEnvironmentMap', environmentMap)

  lovr.graphics.setBackgroundColor(.18, .18, .20)
  lovr.graphics.setCullingEnabled(true)
  lovr.graphics.setBlendMode()
end

function lovr.draw()
  lovr.graphics.skybox(skybox)
  lovr.graphics.setShader(shader)
  model:draw(0, 1.5, -3, 1, lovr.timer.getTime() * .15 - 1)
  lovr.graphics.setShader()
end
