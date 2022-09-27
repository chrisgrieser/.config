local function raycast(rayPos, rayDir, planePos, planeDir)
  local dot = rayDir:dot(planeDir)
  if math.abs(dot) < .001 then
    return nil
  else
    local distance = (planePos - rayPos):dot(planeDir) / dot
    if distance > 0 then
      return rayPos + rayDir * distance
    else
      return nil
    end
  end
end

local button = {
  text = 'Please click me',
  textSize = .1,
  count = 0,
  position = lovr.math.newVec3(0, 1, -3),
  width = 1.0,
  height = .4,
  hover = false,
  active = false
}

local tips = {}

function lovr.update()
  button.hover, button.active = false, false

  for i, hand in ipairs(lovr.headset.getHands()) do
    tips[hand] = tips[hand] or lovr.math.newVec3()

    -- Ray info:
    local rayPosition = vec3(lovr.headset.getPosition(hand))
    local rayDirection = vec3(quat(lovr.headset.getOrientation(hand)):direction())

    -- Call the raycast helper function to get the intersection point of the ray and the button plane
    local hit = raycast(rayPosition, rayDirection, button.position, vec3(0, 0, 1))

    local inside = false
    if hit then
      local bx, by, bw, bh = button.position.x, button.position.y, button.width / 2, button.height / 2
      inside = (hit.x > bx - bw) and (hit.x < bx + bw) and (hit.y > by - bh) and (hit.y < by + bh)
    end

    -- If the ray intersects the plane, do a bounds test to make sure the x/y position of the hit
    -- is inside the button, then mark the button as hover/active based on the trigger state.
    if inside then
      if lovr.headset.isDown(hand, 'trigger') then
        button.active = true
      else
        button.hover = true
      end

      if lovr.headset.wasReleased(hand, 'trigger') then
        button.count = button.count + 1
        print('BOOP')
      end
    end

    -- Set the end position of the pointer.  If the raycast produced a hit position then use that,
    -- otherwise extend the pointer's ray outwards by 50 meters and use it as the tip.
    tips[hand]:set(inside and hit or (rayPosition + rayDirection * 50))
  end
end

function lovr.draw()
  -- Button background
  if button.active then
    lovr.graphics.setColor(.4, .4, .4)
  elseif button.hover then
    lovr.graphics.setColor(.2, .2, .2)
  else
    lovr.graphics.setColor(.1, .1, .1)
  end
  lovr.graphics.plane('fill', button.position, button.width, button.height)

  -- Button text (add a small amount to the z to put the text slightly in front of button)
  lovr.graphics.setColor(1, 1, 1)
  lovr.graphics.print(button.text, button.position + vec3(0, 0, .001), button.textSize)
  lovr.graphics.print('Count: ' .. button.count, button.position + vec3(0, .5, 0), .1)

  -- Pointers
  for hand, tip in pairs(tips) do
    local position = vec3(lovr.headset.getPosition(hand))

    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.sphere(position, .01)

    if button.active then
      lovr.graphics.setColor(0, 1, 0)
    else
      lovr.graphics.setColor(1, 0, 0)
    end
    lovr.graphics.line(position, tip)
    lovr.graphics.setColor(1, 1, 1)
  end
end
