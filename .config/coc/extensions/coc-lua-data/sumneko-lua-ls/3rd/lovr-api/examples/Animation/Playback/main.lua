--[[
  Model by StrykerDoesAnimation
  https://sketchfab.com/models/e8ca2615b4304c3bacb780b0685d8a05
  CC Attribution
]]

function lovr.load()
  model = lovr.graphics.newModel('scytha/scene.gltf')
  shader = lovr.graphics.newShader('unlit', {
    flags = { animated = true }
  })
end

function lovr.update(dt)
  model:animate(1, lovr.timer.getTime())
end

function lovr.draw()
  lovr.graphics.setShader(shader)
  model:draw(0, 0, -4, .2)
  lovr.graphics.setShader()
end
