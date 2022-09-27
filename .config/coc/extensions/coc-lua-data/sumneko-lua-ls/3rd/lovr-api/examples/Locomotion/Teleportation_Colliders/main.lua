-- right trigger: teleport-jump to targeted location
-- right thumbstick: rotate the view horizontally

local physicsWorld
local columns = {}

local motion = {
  pose = lovr.math.newMat4(), -- Transformation in VR initialized to origin (0,0,0) looking down -Z
  thumbstickDeadzone = 0.4,   -- Smaller thumbstick displacements are ignored (too much noise)
  -- Snap motion parameters
  snapTurnAngle = 2 * math.pi / 12,
  thumbstickCooldownTime = 0.3,
  thumbstickCooldown = 0,
  -- Teleport motion parameters
  teleportDistance = 12,
  blinkTime = 0.05,
  blinkStopwatch = math.huge,
  teleportValid = false,
  targetPosition = lovr.math.newVec3(),
  teleportCurve = lovr.math.newCurve(3),
}

function motion.teleport(dt)
  -- Teleportation determining target position and executing jump when triggered
  local handPose = mat4(motion.pose):mul(mat4(lovr.headset.getPose('right')))
  local handPosition = vec3(handPose)
  local handDirection = quat(handPose):direction()
  -- Intersect with world geometry by casting a ray
  local origin = vec3(handPose:mul(0, 0, -0.2))
  local target = vec3(handPose:mul(0, 0, -motion.teleportDistance))
  local intersectionDistance = math.huge
  local closestHit
  physicsWorld:raycast(origin, target,
    function(shape, x, y, z, nx, ny, nz)
      local position = vec3(x, y, z)
      local normal = vec3(nx, ny, nz)
      local distance = (origin - position):length()
      -- Teleportation is possible if distance is within range and if surface is roughly horizontal
      if distance < intersectionDistance and normal:dot(vec3(0,1,0)) > 0.5 then
        intersectionDistance = distance
        closestHit = position
      end
    end)
  if closestHit then
    motion.teleportValid = true
    motion.targetPosition:set(closestHit)
  else
    motion.teleportValid = false
    motion.targetPosition:set(handPose:mul(0,0,-20))
  end
  -- Construct teleporter visualization curve 
  local midPoint = vec3(handPosition):lerp(motion.targetPosition, 0.3)
  if motion.teleportValid then
    midPoint:add(vec3(0, 0.1 * intersectionDistance, 0)) -- Fake a parabola
  end
  motion.teleportCurve:setPoint(1, handPosition)
  motion.teleportCurve:setPoint(2, midPoint)
  motion.teleportCurve:setPoint(3, motion.targetPosition)
  -- Start timer when jump is triggered, preform jump on half-blink
  if lovr.headset.wasPressed('right', 'trigger') and motion.teleportValid then
    motion.blinkStopwatch = -motion.blinkTime / 2
  end
  -- Preform jump with VR pose offset by relative distance between here and there
  if motion.blinkStopwatch < 0 and
     motion.blinkStopwatch + dt >= 0 then
    local headsetXZ = vec3(lovr.headset.getPosition())
    headsetXZ.y = 0
    local newPosition = motion.targetPosition - headsetXZ
    motion.pose:set(newPosition, vec3(1,1,1), quat(motion.pose)) -- ZAAPP
  end
  -- Snap horizontal turning (often combined with teleport mechanics)
  if lovr.headset.isTracked('right') then
    local x, y = lovr.headset.getAxis('right', 'thumbstick')
    if math.abs(x) > motion.thumbstickDeadzone and motion.thumbstickCooldown < 0 then
      local angle = -x / math.abs(x) * motion.snapTurnAngle
      motion.pose:rotate(angle, 0, 1, 0)
      motion.thumbstickCooldown = motion.thumbstickCooldownTime
    end
  end
  motion.blinkStopwatch = motion.blinkStopwatch + dt
  motion.thumbstickCooldown = motion.thumbstickCooldown - dt
end

function motion.drawTeleport()
  if lovr.headset.isTracked('right') then
    -- Teleport target and curve
    lovr.graphics.setColor(1, 1, 1, 0.1)
    if motion.teleportValid then
      lovr.graphics.setColor(1, 1, 0)
      lovr.graphics.cylinder(motion.targetPosition, 0.05, math.pi/2,  1,0,0,  0.4, 0.4)
      lovr.graphics.setColor(1, 1, 1)
    end
    lovr.graphics.setLineWidth(4)
    lovr.graphics.line(motion.teleportCurve:render(30))
  end
  -- Teleport blink, modeled as gaussian function
  local blinkAlpha = math.exp(-(motion.blinkStopwatch/ 0.25 / motion.blinkTime)^2)
  lovr.graphics.setColor(0,0,0, blinkAlpha)
  lovr.graphics.fill()
end



local function makeColumn(x, z, height, color)
  height = math.abs(height)
  local collider = physicsWorld:newCylinderCollider(x, height / 2, z, 2, height)
  local shape = collider:getShapes()[1]
  collider:setOrientation(math.pi/2,  1,0,0)
  collider:setKinematic(true)
  local column = {
    collider=collider,
    shape=shape,
    color=color,
  }
  table.insert(columns, column)
end

function lovr.load()
  physicsWorld = lovr.physics.newWorld()
  -- Some scenery
  lovr.math.setRandomSeed(0)
  local goldenRatio = (math.sqrt(5) + 1) / 2
  local goldenAngle = (2 - goldenRatio) * (2 * math.pi)
  local k = 2.5
  for i = 1, 100 do
    local r = math.sqrt(i) * k
    local x = math.cos(goldenAngle * i) * r
    local z = math.sin(goldenAngle * i) * r
    local height = 5 + 10 * math.exp(-(r/50)^2)
    local shade = 0.1 + 0.3 * lovr.math.random()
    local color = {shade, shade, shade}
    makeColumn(x, z, height, color)
    -- set initial VR position to the top of center column
    if i == 1 then
      motion.pose:set(x, height, z)
    end
  end
end

function lovr.update(dt)
  motion.teleport(dt)
end

function lovr.draw()
  lovr.graphics.setBackgroundColor(0.1, 0.1, 0.1)
  lovr.graphics.transform(mat4(motion.pose):invert())
  -- Render hands
  lovr.graphics.setColor(1, 1, 1)
  local radius = 0.04
  for _, hand in ipairs(lovr.headset.getHands()) do
    -- Whenever pose of hand or head is used, need to account for VR movement
    local poseRW = mat4(lovr.headset.getPose(hand))
    local poseVR = mat4(motion.pose):mul(poseRW)
    poseVR:scale(radius)
    lovr.graphics.sphere(poseVR)
  end
  -- Render columns
  for i, column in ipairs(columns) do
    local x,y,z, angle, ax,ay,az = column.collider:getPose()
    local l, r = column.shape:getLength(), column.shape:getRadius()
    lovr.graphics.setColor(unpack(column.color))
    lovr.graphics.cylinder(x,y,z, l, angle, ax,ay,az, r, r, true, 20)
  end
  -- Teleportation curve and target, rendering of blinking overlay
  motion.drawTeleport()
  lovr.graphics.setColor(1, 1, 1)
end
