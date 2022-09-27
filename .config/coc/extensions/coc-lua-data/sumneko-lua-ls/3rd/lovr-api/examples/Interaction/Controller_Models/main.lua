function lovr.load()
  models = {
    left = lovr.headset.newModel('hand/left'),
    right = lovr.headset.newModel('hand/right')
  }
end

function lovr.draw()
  for hand, model in pairs(models) do
    if lovr.headset.isTracked(hand) then
      model:draw(mat4(lovr.headset.getPose(hand)))
    end
  end
end
