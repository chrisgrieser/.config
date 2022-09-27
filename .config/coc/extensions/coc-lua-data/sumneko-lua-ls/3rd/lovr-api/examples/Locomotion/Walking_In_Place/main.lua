-- Walk or jog in place to move forward

local motion = {
  pose = lovr.math.newMat4(), -- Transformation in VR initialized to origin (0,0,0) looking down -Z
  -- Walk in place parameters
  amplification = 25, -- Walking speed compared to head bob intensity
  damping = 0.15,     -- Lower value adds inertia, higher value makes walking less "floaty"
  -- State
  speed = 0,
  headPitch = 0,
  warmup = 0,
}

-- IIR filter section (direct II form) ------------------------------------------------------------
local formII
formII = {
  new = function(a, b)
    local self = setmetatable({}, formII)
    self.a1, self.a2 = a[2], a[3]                 -- a coefficients (denominator)
    self.b0, self.b1, self.b2 = b[1], b[2], b[3]  -- b coefficients (nominator)
    self.v0, self.v1, self.v2 = 0, 0, 0           -- mid-point calculation and its delays
    return self
  end,
  process = function(self, x)
    self.v2, self.v1 = self.v1, self.v0                               -- process delays
    self.v0 = x - self.a1 * self.v1 - self.a2 * self.v2               -- mid-value
    return self.b0 * self.v0 + self.b1 * self.v1 + self.b2 * self.v2  -- output
  end,
}
formII.__index = formII ---------------------------------------------------------------------------

-- Construct a band-pass filter
--  Coefficients obtained with `butter(1, [1.5,2.8], 'bandpass', False, 'sos', 60)` from scipy.signal
motion.filterSection1 = formII.new({1.0, -1.8587017, 0.9066295}, {0.0029759,  0.0059517, 0.0029759})
motion.filterSection2 = formII.new({1.0, -1.9198555, 0.9394925}, {1.0000000, -2.0000000, 1.0000000})

function motion.walkinplace(dt)
  local _, y, _ = lovr.headset.getPosition('head')
  -- Warm-up phase allows filter to settle in while adapting to user height
  if motion.warmup < 0.5 then
    for i = 1, 20 do
      motion.filterSection2:process(motion.filterSection1:process(y))
    end
    motion.warmup = motion.warmup + dt
    return
  end
  local direction = quat(lovr.headset.getOrientation('head')):direction()
  local pitch = direction.y
  -- Detect pitch changes (looking up/down) and inhibit walking until pitch motion ends
  motion.headPitch = ((pitch - motion.headPitch) * 0.1 + motion.headPitch)
  local pitchChange = math.abs(pitch - motion.headPitch) * 10
  local walkInhibit = math.max(1 - pitchChange, 0)
  -- Estimate intensity of head bob due to walking or jogging
  --  Filter y signal with bandpass to isolate frequencies around 2 Hz
  --  Take absolute value of signal and amplify with parameter
  local filtered = motion.filterSection2:process(motion.filterSection1:process(y))
  local walkIntensity = math.abs(filtered) * motion.amplification
  -- Apply estimated walk intensity to speed
  -- Simple lowpass IIR is applied for smoothness and inertia
  motion.speed = motion.speed * (1 - motion.damping) + walkIntensity * walkInhibit
  direction.y = 0
  motion.pose:translate(direction * motion.speed * dt)
end


function lovr.update(dt)
  motion.walkinplace(dt)
end

function lovr.draw()
  lovr.graphics.setBackgroundColor(0.1, 0.1, 0.1)
  lovr.graphics.print(string.format('%2.3f', motion.speed), 19, 1, -15, 0.05)
  lovr.graphics.transform(mat4(motion.pose):invert())
  -- Render hands
  lovr.graphics.setColor(1,1,1)
  local radius = 0.04
  for _, hand in ipairs(lovr.headset.getHands()) do
    -- Whenever pose of hand or head is used, need to account for VR movement
    local poseRW = mat4(lovr.headset.getPose(hand))
    local poseVR = mat4(motion.pose):mul(poseRW)
    poseVR:scale(radius)
    lovr.graphics.sphere(poseVR)
  end
  -- Some scenery
  lovr.math.setRandomSeed(0)
  local goldenRatio = (math.sqrt(5) + 1) / 2
  local goldenAngle = (2 - goldenRatio) * (2 * math.pi)
  local k = 1.8
  for i = 1, 500 do
    local r = math.sqrt(i) * k
    local x = math.cos(goldenAngle * i) * r
    local y = math.sin(goldenAngle * i) * r
    if lovr.math.random() < 0.05 then
      lovr.graphics.setColor(0.5, 0, 0)
    else
      local shade = 0.1 + 0.3 * lovr.math.random()
      lovr.graphics.setColor(shade, shade, shade)
    end
    lovr.graphics.cylinder(x, -0.01, y,  0.02, math.pi / 2, 1,0,0, 1, 1)
  end
end
