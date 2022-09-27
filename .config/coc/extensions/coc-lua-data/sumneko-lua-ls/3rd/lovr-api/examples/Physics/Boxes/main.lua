function lovr.load()
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)

  -- Create the ground
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)

  -- Create boxes!
  boxes = {}
  for x = -1, 1, .25 do
    for y = .125, 2, .24999 do
      local box = world:newBoxCollider(x, y, -2 - y / 5, .25)
      table.insert(boxes, box)
    end
  end

  controllerBoxes = {}

  lovr.timer.step() -- Reset the timer before the first update

  shader = lovr.graphics.newShader('standard')
  shader:send('lovrExposure', 2)
end

function lovr.update(dt)
  -- Update the physics simulation
  world:update(dt)

  -- Place boxes on controllers
  for i, hand in ipairs(lovr.headset.getHands()) do
    if not controllerBoxes[i] then
      controllerBoxes[i] = world:newBoxCollider(0, 0, 0, .25)
      controllerBoxes[i]:setKinematic(true)
    end
    controllerBoxes[i]:setPose(lovr.headset.getPose(hand))
  end
end

-- A helper function for drawing boxes
function drawBox(box)
  local x, y, z = box:getPosition()
  lovr.graphics.cube('fill', x, y, z, .25, box:getOrientation())
end

function lovr.draw()
  lovr.graphics.setBackgroundColor(.8, .8, .8)
  lovr.graphics.setShader(shader)

  lovr.graphics.setColor(1, 0, 0)
  for i, box in ipairs(boxes) do
    drawBox(box)
  end

  if lovr.headset.getDriver() ~= 'desktop' then
    lovr.graphics.setColor(0, 0, 1)
    for i, box in ipairs(controllerBoxes) do
      drawBox(box)
    end
  end

  lovr.graphics.setColor(1, 1, 1)
  lovr.graphics.setShader()
end
