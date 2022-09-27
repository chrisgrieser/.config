function lovr.draw()
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = vec3(lovr.headset.getPosition(hand))
    local direction = quat(lovr.headset.getOrientation(hand)):direction()

    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.sphere(position, .01)

    lovr.graphics.setColor(1, 0, 0)
    lovr.graphics.line(position, position + direction * 50)
  end
end
