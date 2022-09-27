-- Note: Wireframe rendering doesn't work in WebGL

function lovr.load()
  model = lovr.graphics.newModel('suzanne.obj')
end

function lovr.draw()
  lovr.graphics.setWireframe(true)
  model:draw(0, 1.7, -3, 1, lovr.timer.getTime() * .25)
  lovr.graphics.setWireframe(false)
end
