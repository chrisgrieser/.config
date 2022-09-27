--[[ Hand interaction with physics world: use trigger to solidify hand, grip to grab objects

To manipulate objects in world, we create box collider (palm) for each hand controller. This box
is updated to track location of controller.

The naive approach would be to set exact location and orientation of physical collider with values
from hand controller. This results in lousy and unconvincing collisions with other objects, as
physics engine doesn't know the speed of hand colliders at the moment of collision.

An improvement is to set linear and angular speed of kinematic hand colliders so that they
approach the target (actual location/orientation of hand controller). This works excellent for one
controller. When you try to squeeze an object between two hands, physics break. This is because
kinematic hand controllers are never affected by physics engine and unrealistic material
penetration cannot be resolved.

The approach taken here is to have hand controllers behave as normal dynamic colliders that can be
affected by other collisions. To track hand controllers, we apply force and torque on collider
objects that's proportional to distance from correct position.

This means hand colliders won't have 1:1 mapping with actual hand controllers, they will actually
'bend' under large force. Also the colliders can actually become stuck behind another object. This
is sometimes frustrating to use, so in this example hand colliders can ghost through objects or
become solid using trigger button.

Grabbing objects is done by creating two joints between hand collider and object to hold them
together. This enables pulling, stacking and throwing.                                      --]]

local hands = { -- palms that can push and grab objects
  colliders = {nil, nil},     -- physical objects for palms
  touching  = {nil, nil},     -- the collider currently touched by each hand
  holding   = {nil, nil},     -- the collider attached to palm
  solid     = {false, false}, -- hand can either pass through objects or be solid
} -- to be filled with as many hands as there are active controllers

local world
local collisionCallbacks = {}
local boxes = {}

local framerate = 1 / 72 -- fixed framerate is recommended for physics updates

function lovr.load()
  world = lovr.physics.newWorld(0, -2, 0, false) -- low gravity and no collider sleeping
  -- ground plane
  local box = world:newBoxCollider(vec3(0, 0, 0), vec3(20, 0.1, 20))
  box:setKinematic(true)
  table.insert(boxes, box)
  -- create a fort of boxes
  lovr.math.setRandomSeed(0)
  for angle = 0, 2 * math.pi, 2 * math.pi / 12 do
    for height = 0.3, 1.5, 0.4 do
      local pose = mat4():rotate(angle, 0,1,0):translate(0, height, -1)
      local size = vec3(0.3, 0.4, 0.2)
      local box = world:newBoxCollider(vec3(pose), size)
      box:setOrientation(quat(pose))
      table.insert(boxes, box)
    end
  end
  -- make colliders for two hands
  for i = 1, 2 do
    hands.colliders[i] = world:newBoxCollider(vec3(0,2,0), vec3(0.04, 0.08, 0.08))
    hands.colliders[i]:setLinearDamping(0.2)
    hands.colliders[i]:setAngularDamping(0.3)
    hands.colliders[i]:setMass(0.1)
    registerCollisionCallback(hands.colliders[i],
      function(collider, world)
        -- store collider that was last touched by hand
        hands.touching[i] = collider
      end)
  end
end


function lovr.update(dt)
  -- override collision resolver to notify all colliders that have registered their callbacks
  world:update(framerate, function(world)
    world:computeOverlaps()
    for shapeA, shapeB in world:overlaps() do
      local areColliding = world:collide(shapeA, shapeB)
      if areColliding then
        cbA = collisionCallbacks[shapeA]
        if cbA then cbA(shapeB:getCollider(), world) end
        cbB = collisionCallbacks[shapeB]
        if cbB then cbB(shapeA:getCollider(), world) end
      end
    end
  end)
  -- hand updates - location, orientation, solidify on trigger button, grab on grip button
  for i, hand in pairs(lovr.headset.getHands()) do
    -- align collider with controller by applying force (position) and torque (orientation)
    local rw = mat4(lovr.headset.getPose(hand))   -- real world pose of controllers
    local vr = mat4(hands.colliders[i]:getPose()) -- vr pose of palm colliders
    local angle, ax,ay,az = quat(rw):mul(quat(vr):conjugate()):unpack()
    angle = ((angle + math.pi) % (2 * math.pi) - math.pi) -- for minimal motion wrap to (-pi, +pi) range
    hands.colliders[i]:applyTorque(vec3(ax, ay, az):mul(angle * dt * 1))
    hands.colliders[i]:applyForce((vec3(rw:mul(0,0,0)) - vec3(vr:mul(0,0,0))):mul(dt * 2000))
    -- solidify when trigger touched
    hands.solid[i] = lovr.headset.isDown(hand, 'trigger')
    hands.colliders[i]:getShapes()[1]:setSensor(not hands.solid[i])
    -- hold/release colliders
    if lovr.headset.isDown(hand, 'grip') and hands.touching[i] and not hands.holding[i] then
      hands.holding[i] = hands.touching[i]
      lovr.physics.newBallJoint(hands.colliders[i], hands.holding[i], vr:mul(0,0,0))
      lovr.physics.newSliderJoint(hands.colliders[i], hands.holding[i], quat(vr):direction())
    end
    if lovr.headset.wasReleased(hand, 'grip') and hands.holding[i] then
      for _,joint in ipairs(hands.colliders[i]:getJoints()) do
        joint:destroy()
      end
      hands.holding[i] = nil
    end
  end
  hands.touching = {nil, nil} -- to be set again in collision resolver
end


function lovr.draw()
  for i, collider in ipairs(hands.colliders) do
    local alpha = hands.solid[i] and 1 or 0.2
    lovr.graphics.setColor(0.75, 0.56, 0.44, alpha)
    drawBoxCollider(collider)
  end
  lovr.math.setRandomSeed(0)
  for i, collider in ipairs(boxes) do
    local shade = 0.2 + 0.6 * lovr.math.random()
    lovr.graphics.setColor(shade, shade, shade)
    drawBoxCollider(collider)
  end
end


function drawBoxCollider(collider)
  -- query current pose (location and orientation)
  local pose = mat4(collider:getPose())
  -- query dimensions of box
  local shape = collider:getShapes()[1]
  local size = vec3(shape:getDimensions())
  -- draw box
  pose:scale(size)
  lovr.graphics.box('fill', pose)
end


function registerCollisionCallback(collider, callback)
  collisionCallbacks = collisionCallbacks or {}
  for _, shape in ipairs(collider:getShapes()) do
    collisionCallbacks[shape] = callback
  end
  -- to be called with arguments callback(otherCollider, world) from update function
end
