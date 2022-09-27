local random = lovr.math.random
local boxes = {}
local selectedBox = nil
local hitpoint = lovr.math.newVec3()
local red = { 1, .5, .5 }
local green = { .5, 1, .5 }

function lovr.load()
  lovr.graphics.setBackgroundColor(.2, .2, .22)
  world = lovr.physics.newWorld(0, 0, 0)

  -- Make a bunch of random spinning boxes XD
  for x = -3, 3 do
    for z = 1, 10 do
      local y = .5 + lovr.math.randomNormal(.1)
      local box = world:newBoxCollider(x, y, -z, .28)
      box:setOrientation(random(2 * math.pi), random(), random(), random())
      box:setAngularVelocity(random(), random(), random())
      table.insert(boxes, box)
    end
  end
end

function lovr.update(dt)
  selectedBox = nil

  world:update(dt)

  local ox, oy, oz = lovr.headset.getPosition('hand/right')
  local dx, dy, dz = quat(lovr.headset.getOrientation('hand/right')):direction():mul(50):unpack()
  local closest = math.huge
  world:raycast(ox, oy, oz, ox + dx, oy + dy, oz + dz, function(shape, x, y, z)
    local distance = vec3(x, y, z):distance(vec3(ox, oy, oz))
    if distance < closest then
      selectedBox = shape:getCollider()
      hitpoint:set(x, y, z)
      closest = distance
    end
  end)
end

function lovr.draw()
  -- Boxes
  for i, box in ipairs(boxes) do
    lovr.graphics.setColor(box == selectedBox and green or red)
    lovr.graphics.cube('fill', vec3(box:getPosition()), .28, quat(box:getOrientation()))
  end

  -- Dot
  if selectedBox then
    lovr.graphics.setColor(0, 0, 1)
    lovr.graphics.sphere(hitpoint, .01)
  end

  -- Laser pointer
  local hand = vec3(lovr.headset.getPosition('hand/right'))
  local direction = quat(lovr.headset.getOrientation('hand/right')):direction()
  lovr.graphics.setColor(1, 1, 1)
  lovr.graphics.line(hand, selectedBox and hitpoint or (hand + direction * 50))
end
