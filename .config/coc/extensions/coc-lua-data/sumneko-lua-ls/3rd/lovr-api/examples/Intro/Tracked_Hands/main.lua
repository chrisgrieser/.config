function lovr.draw()
  for i, hand in ipairs(lovr.headset.getHands()) do
    local x, y, z = lovr.headset.getPosition(hand)
    lovr.graphics.sphere(x, y, z, .1)
  end
end
