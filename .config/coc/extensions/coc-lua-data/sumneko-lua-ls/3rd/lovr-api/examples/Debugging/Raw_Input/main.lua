-- Display all input devices as floating text
-- Sample contributed by andi mcc

local function appendMovement(s, device)
  a,b,c = lovr.headset.getVelocity(device) a = a or -999 b = b or -999 c = c or -9999
  s = string.format("%s vel %1.1f,%1.1f,%1.1f", s,a,b,c)
  a,b,c = lovr.headset.getAngularVelocity(device) a = a or -999 b = b or -999 c = c or -9999
  s = string.format("%s   ang %1.1f,%1.1f,%1.1f", s,a,b,c)
  return s
end

local lines = {}
local function lineWidth(i, w)
  lines[i] = lines[i] and math.max(lines[i], w) or w
  return lines[i]
end
local controllerData = {}
local function controllerFetch(k)
  if not controllerData[k] then controllerData[k] = {} end
  return controllerData[k]
end

local function drawText()
  local hands = lovr.headset.getHands()
  -- Head
  local s = {string.format("%d controllers", #hands),
             appendMovement("head ", "head")}
  for i,controller in ipairs(hands) do
  	local c = controllerFetch(controller)
    table.insert(s, false)
    -- Axes
    local axes = ""
    for i2, axis in ipairs{"touchpad", "thumbstick"} do
      local x,y = lovr.headset.getAxis(controller, axis)
      if x and y and (x ~= 0 or y ~= 0) then c[axis] = true end
      if c[axis] then -- Show an axis if it is, or ever has been, non-nil non-zero
        axes = string.format("%s%s x %1.1f, y %1.1f; ", axes, axis, x,y)
      end
    end
    -- Controller name and axes
    table.insert(s, string.format("%d (%s): %strig %1.1f; grip %1.1f", i, controller, axes, lovr.headset.getAxis(controller, "trigger") or -999, lovr.headset.getAxis(controller, "grip") or -999))
    s[#s] = appendMovement(s[#s], controller)
    -- Buttons
    table.insert(s, "DOWN")
    for i,name in ipairs({"grip", "trigger", "touchpad", "thumbstick", "menu", "a", "b", "x", "y"}) do
    	s[#s] = string.format("%s %s:%d", s[#s], name, lovr.headset.isDown(controller, name) and 1 or 0)
    end
    table.insert(s, "TOUCH")
    for i,name in ipairs({"grip", "trigger", "touchpad", "thumbstick", "menu", "a", "b", "x", "y"}) do
    	s[#s] = string.format("%s %s:%d", s[#s], name, lovr.headset.isTouched(controller, name) and 1 or 0)
    end
  end
  -- Display
  local font = lovr.graphics.getFont()
  local fh = font:getHeight()/2 -- Half size render
  local top = 2 + fh*#s/2
  for i,line in ipairs(s) do -- Manually center using maximum width of each line so it jiggles less
    if line then
      local w = lineWidth(i, font:getWidth(line))
      lovr.graphics.print(line, -w/2/2, top-fh*i, -3, .5, 0,0,1,0,0, "left")
    end
  end
end

function lovr.draw()
	drawText()
end
