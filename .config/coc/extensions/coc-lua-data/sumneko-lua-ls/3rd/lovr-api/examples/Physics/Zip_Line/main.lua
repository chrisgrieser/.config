--[[ A zipline made of

Capsule is suspended from trolley using distance joint. Trolley is attached to hanger
using slider joint. Beware that slider joint loses its accuracy/stability when attached
objects are too far away. Increasing object mass of helps with stability.            --]]

local world

function lovr.load()
  world = lovr.physics.newWorld(0, -3, 0, false)
  local hanger = world:newBoxCollider(vec3(1, 1.9, -1), vec3(0.1, 0.1, 0.3))
  hanger:setKinematic(true)
  local trolley = world:newBoxCollider(vec3(-1, 2, -1), vec3(0.2, 0.2, 0.5))
  trolley:setRestitution(0.7)
  -- calculate axis that passes through centers of hanger and trolley
  local sliderAxis = vec3(hanger:getPosition()) - vec3(trolley:getPosition())
  -- constraint the trolley so that it can only slide along specified axis without any rotation
  joint = lovr.physics.newSliderJoint(hanger, trolley, sliderAxis)
  -- hang a weight from trolley
  local weight = world:newCapsuleCollider(vec3(-1, 1.5, -1), 0.1, 0.4)
  weight:setOrientation(math.pi/2, 1,0,0)
  weight:setLinearDamping(0.005)
  weight:setAngularDamping(0.01)
  local joint = lovr.physics.newDistanceJoint(trolley, weight, vec3(trolley:getPosition()), vec3(weight:getPosition()) + vec3(0, 0.3, 0))
  joint:setResponseTime(10) -- make the hanging rope streachable

  lovr.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end


function lovr.update(dt)
  world:update(1 / 72)
end


function lovr.draw()
  for i, collider in ipairs(world:getColliders()) do
    lovr.graphics.setColor(0.6, 0.6, 0.6)
    local shape = collider:getShapes()[1]
    local shapeType = shape:getType()
    local x,y,z, angle, ax,ay,az = collider:getPose()
    if shapeType == 'box' then
      local sx, sy, sz = shape:getDimensions()
      lovr.graphics.box('fill', x,y,z, sx,sy,sz, angle, ax,ay,az)
    elseif shapeType == 'capsule' then
      lovr.graphics.setColor(0.4, 0, 0)
      local l, r = shape:getLength(), shape:getRadius()
      local x,y,z, angle, ax,ay,az = collider:getPose()
      local m = mat4(x,y,z, 1,1,1, angle, ax,ay,az)
      lovr.graphics.cylinder(x,y,z, l, angle, ax,ay,az, r, r, false)
      lovr.graphics.sphere(vec3(m:mul(0, 0,  l/2)), r)
      lovr.graphics.sphere(vec3(m:mul(0, 0, -l/2)), r)
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
