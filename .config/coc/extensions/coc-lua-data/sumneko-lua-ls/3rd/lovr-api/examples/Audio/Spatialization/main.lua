function lovr.load()
  effects = { 'spatialization', 'attenuation' }
  source = lovr.audio.newSource('sine.wav', { effects = effects })
  source:setLooping(true)
  source:play()
end

function lovr.update()
  lovr.audio.setPose(lovr.headset.getPose())

  local x = math.sin(lovr.timer.getTime() * 2)
  source:setPose(x, 1, -1)
end

function lovr.draw()
  lovr.graphics.sphere(mat4(source:getPose()):scale(.05))
end
