--[[ Wrecking ball suspended from rope. Cyrus-free.

Making realtime rope simulation is finicky on any physics engine. At certain weight the force becomes
too much to be successfully distributed among rope elements.

Some steps that can help solve the issue:
1) lower the mass of suspended weight or lower the gravity constant
2) increase mass of each rope element, preferably having more mass at top of rope and less mass at bottom
3) decrease number of rope elements
4) decrease the simulation time step
5) modify engine code to use direct solver instead of iterative solver (step() instead of quickStep())
--]]

local world

function lovr.load()
  world = lovr.physics.newWorld(0, -3, 0, false)
  -- ground plane
  local box = world:newBoxCollider(vec3(0, -0.05, 0), vec3(20, 0.1, 20))
  box:setKinematic(true)
  -- hanger
  local hangerPosition = vec3(0, 2, -1)
  local hanger = world:newBoxCollider(hangerPosition, vec3(0.3, 0.1, 0.3))
  hanger:setKinematic(true)
  -- ball
  local ballPosition = vec3(-1, 1, -1)
  local ball = world:newSphereCollider(ballPosition, 0.2)
  -- rope
  local firstEnd, lastEnd = makeRope(
    hangerPosition + vec3(0, -0.1, 0),
    ballPosition   + vec3(0,  0.3, 0),
    0.02, 10)
  lovr.physics.newDistanceJoint(hanger, firstEnd, hangerPosition, vec3(firstEnd:getPosition()))
  lovr.physics.newDistanceJoint(ball, lastEnd, ballPosition, vec3(lastEnd:getPosition()))
  -- brick wall
  local x = 0.3
  local even = true
  for y = 1, 0.1, -0.1 do
    for z = -0.5, -1.5, -0.2 do
      world:newBoxCollider(x, y, even and z or z - 0.1, 0.08, 0.1, 0.2)
    end
    even = not even
  end

  lovr.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end


function lovr.update(dt)
  world:update(1 / 72)
end


function lovr.draw()
  for i, collider in ipairs(world:getColliders()) do
    local shade = (i - 10) / #world:getColliders()
    lovr.graphics.setColor(shade, shade, shade)
    local shape = collider:getShapes()[1]
    local shapeType = shape:getType()
    local x,y,z, angle, ax,ay,az = collider:getPose()
    if shapeType == 'box' then
      local sx, sy, sz = shape:getDimensions()
      lovr.graphics.box('fill', x,y,z, sx,sy,sz, angle, ax,ay,az)
    elseif shapeType == 'sphere' then
      lovr.graphics.setColor(0.4, 0, 0)
      lovr.graphics.sphere(x,y,z, shape:getRadius())
    end
  end
end


function makeRope(origin, destination, thickness, elements)
  local length = (destination - origin):length()
  thickness = thickness or length / 100
  elements = elements or 30
  elementSize = length / elements
  local orientation = vec3(destination - origin):normalize()
  local first, last, prev
  for i = 1, elements do
    local position = vec3(origin):lerp(destination, (i - 0.5) / elements)
    local anchor   = vec3(origin):lerp(destination, (i - 1.0) / elements)
    element = world:newBoxCollider(position, vec3(thickness, thickness, elementSize * 0.95))
    element:setRestitution(0.1)
    element:setGravityIgnored(true)
    element:setOrientation(quat(orientation))
    element:setLinearDamping(0.01)
    element:setAngularDamping(0.01)
    element:setMass(0.001)
    if prev then
      local joint = lovr.physics.newBallJoint(prev, element, anchor)
      joint:setResponseTime(10)
      joint:setTightness(1)
    else
      first = element
    end
    prev = element
  end
  last = prev
  return first, last
end
