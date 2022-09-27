--[[ A utility function that draws all possible physics colliders and joint geometry

Useful for debugging physics (to see if colliders line up with rendered geometry),
and for experimenting and prototyping with physics, to get the rendering out of way.   --]]

local world
local count = 100

function lovr.load()
  gravity = gravity or 2
  sleepingAllowed = sleepingAllowed or false
  world = lovr.physics.newWorld(0, -gravity, 0, sleepingAllowed)
  -- ground plane
  local box = world:newBoxCollider(vec3(0, 0, 0), vec3(20, 0.1, 20))
  box:setKinematic(true)
  box:setUserData({1, 1, 1})
end


function lovr.update(dt)
  world:update(1 / 72) -- simulation is more stable if executed with fixed step
  -- every 100ms add random shape until there's enough of them
  if lovr.timer.getTime() % 0.1 < dt and count > 0 then
    local collider
    local colliderType = ({'box', 'sphere', 'cylinder', 'capsule'})[count % 4 + 1]
    local position = vec3(2 - 4 * lovr.math.random(), 4, 1 - 2 * lovr.math.random())
    if     colliderType == 'box' then
      local size = vec3(0.1, 0.2, 0.3)
      collider = world:newBoxCollider(position, size)
    elseif colliderType == 'sphere' then
      local radius = 0.2
      collider = world:newSphereCollider(position, radius)
    elseif colliderType == 'cylinder' then
      local radius, length = 0.1, 0.3
      collider = world:newCylinderCollider(position, radius, length)
    elseif colliderType == 'capsule' then
      local radius, length = 0.1, 0.3
      collider = world:newCapsuleCollider(position, radius, length)
    end
    local shade = 0.2 + 0.6 * lovr.math.random()
    collider:setUserData({shade, shade, shade})
    collider:setOrientation(math.pi, lovr.math.random(), lovr.math.random(), lovr.math.random())
    count = count - 1
  end
end


function lovr.draw()
  for i, collider in ipairs(world:getColliders()) do
    -- rendering shapes of each collider
    drawCollider(collider)
    -- debug geometry for joints (no joints are used in this example)
    drawAttachedJoints(collider)
  end
end


function drawCollider(collider)
  local color = collider:getUserData()
  lovr.graphics.setColor(color or 0x202020)
  local shape = collider:getShapes()[1]
  if shape:isSensor() then
    local r,g,b = lovr.graphics.getColor()
    lovr.graphics.setColor(r,g,b,0.2)
  end
  -- shapes
  for _, shape in ipairs(collider:getShapes()) do
    local shapeType = shape:getType()
    local x,y,z, angle, ax,ay,az = collider:getPose()
    -- draw primitive at collider's position with correct dimensions
    if shapeType == 'box' then
      local sx, sy, sz = shape:getDimensions()
      lovr.graphics.box('fill', x,y,z, sx,sy,sz, angle, ax,ay,az)
    elseif shapeType == 'sphere' then
      lovr.graphics.sphere(x,y,z, shape:getRadius())
    elseif shapeType == 'cylinder' then
      local l, r = shape:getLength(), shape:getRadius()
      local x,y,z, angle, ax,ay,az = collider:getPose()
      lovr.graphics.cylinder(x,y,z, l, angle, ax,ay,az, r, r)
    elseif shapeType == 'capsule' then
      local l, r = shape:getLength(), shape:getRadius()
      local x,y,z, angle, ax,ay,az = collider:getPose()
      local m = mat4(x,y,z, 1,1,1, angle, ax,ay,az)
      lovr.graphics.cylinder(x,y,z, l, angle, ax,ay,az, r, r, false)
      lovr.graphics.sphere(vec3(m:mul(0, 0,  l/2)), r)
      lovr.graphics.sphere(vec3(m:mul(0, 0, -l/2)), r)
    end
  end
end


function drawAttachedJoints(collider)
  lovr.graphics.setColor(1,1,1,0.3)
  -- joints are attached to two colliders; function draws joint for second collider
  for j, joint in ipairs(collider:getJoints()) do
    local anchoring, attached = joint:getColliders()
    if attached == collider then
      jointType = joint:getType()
      if jointType == 'ball' then
        local x1, y1, z1, x2, y2, z2 = joint:getAnchors()
        drawAnchor(vec3(x1,y1,z1))
        drawAnchor(vec3(x2,y2,z2))
      elseif jointType == 'slider' then
        local position = joint:getPosition()
        local x,y,z = anchoring:getPosition()
        drawAxis(vec3(x,y,z), vec3(joint:getAxis()))
      elseif jointType == 'distance' then
        local x1, y1, z1, x2, y2, z2 = joint:getAnchors()
        drawAnchor(vec3(x1,y1,z1))
        drawAnchor(vec3(x2,y2,z2))
        drawAxis(vec3(x2,y2,z2), vec3(x1, y1, z1) - vec3(x2,y2,z2))
      elseif jointType == 'hinge' then
        local x1, y1, z1, x2, y2, z2 = joint:getAnchors()
        drawAnchor(vec3(x1,y1,z1))
        drawAnchor(vec3(x2,y2,z2))
        drawAxis(vec3(x1,y1,z1), vec3(joint:getAxis()))
      end
    end
  end
end


function drawAnchor(origin)
  lovr.graphics.sphere(origin, .02)
end


function drawAxis(origin, axis)
  lovr.graphics.line(origin, origin + axis:normalize() * 0.3)
end
