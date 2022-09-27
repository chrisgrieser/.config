-- Newton's cradle: array of balls suspended from two strings, demonstrating conservation of energy / momentum
-- Strings are modeled with distance joints, which means they behave more like rods.

local world
local frame
local framePose
local balls = {}
local count = 10
local radius = 1 / count / 2
-- small air gap between balls results in collisions in separate frames, to carry impulse through to last ball
-- without this gap the physics engine would need to calculate transfer of impulses between contacts
local gap = 0.01


function lovr.load()
  world = lovr.physics.newWorld(0, -9.8, 0, false)
  -- a static geometry from which balls are suspended
  local size = vec3(1.2, 0.1, 0.3)
  frame = world:newBoxCollider(vec3(0, 2, -1), size)
  frame:setKinematic(true)
  framePose = lovr.math.newMat4(frame:getPose()):scale(size)
  -- create balls along the length of frame and attach them with two distance joints to frame
  for x = -0.5, 0.5, 1 / count do
    local ball = world:newSphereCollider(vec3(x, 1, -1), radius - gap)
    ball:setRestitution(1)
    lovr.physics.newDistanceJoint(frame, ball, vec3(x, 2, -1 + 0.25), vec3(x, 1, -1))
    lovr.physics.newDistanceJoint(frame, ball, vec3(x, 2, -1 - 0.25), vec3(x, 1, -1))
    table.insert(balls, ball)
  end
  -- displace the last ball to set the Newton's cradle in motion
  local lastBall = balls[#balls]
  lastBall:setPosition(vec3(lastBall:getPosition()) + vec3(5 * radius, 5 * radius, 0))
  lovr.graphics.setBackgroundColor(0.1, 0.1, 0.1)
end


function lovr.draw()
  lovr.graphics.setColor(0, 0, 0)
  lovr.graphics.box('fill', framePose)
  lovr.graphics.setColor(1, 1, 1)
  for i, ball in ipairs(balls) do
    local position = vec3(ball:getPosition())
    lovr.graphics.sphere(position, radius)
  end
end


function lovr.update(dt)
  world:update(1 / 72)
end
