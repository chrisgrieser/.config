-- Saloon doors attached with hinge joint to frame, and with distance joint to each other

local world
local door1, door2

function lovr.load()
  world = lovr.physics.newWorld(0, -9.8, 0, false)
  -- a static geometry that functions as door frame
  local frame = world:newBoxCollider(vec3(0, -0.1, -1), vec3(2.2, 0.05, 0.2))
  frame:setKinematic(true)
  door1 = world:newBoxCollider(vec3( 0.55, 0.5, -1), vec3(1, 1, 0.2))
  door2 = world:newBoxCollider(vec3(-0.55, 0.5, -1), vec3(1, 1, 0.2))
  door1:setAngularDamping(0.01)
  door2:setAngularDamping(0.01)
  -- attach doors to frame, with hinges being oriented vertically (up vector is 0,1,0)
  lovr.physics.newHingeJoint(frame, door1, vec3( 1, 0, -1), vec3(0,1,0))
  lovr.physics.newHingeJoint(frame, door2, vec3(-1, 0, -1), vec3(0,1,0))
  -- model door springiness by attaching loose distance joint between two doors
  local joint = lovr.physics.newDistanceJoint(door1, door2, vec3(door1:getPosition()), vec3(door2:getPosition()))
  joint:setTightness(0.2)
  joint:setResponseTime(10)
  lovr.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end

function lovr.draw()
  for i, boxCollider in ipairs(world:getColliders()) do
    lovr.graphics.setColor(i / 3, i / 3, i / 3)
    local pose = mat4(boxCollider:getPose())
    local size = vec3(boxCollider:getShapes()[1]:getDimensions())
    lovr.graphics.box('fill', pose:scale(size))
  end
end

function lovr.update(dt)
  world:update(1 / 72)
  -- every few seconds simulate a push
  if lovr.timer.getTime() % 3 < dt then
    door1:applyForce(0, 0, -50)
    door2:applyForce(0, 0, -50)
  end
end
