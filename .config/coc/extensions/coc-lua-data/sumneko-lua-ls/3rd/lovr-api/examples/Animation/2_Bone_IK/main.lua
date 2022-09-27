local function solve(root, target, control, lengths)
  local T = vec3(target - root)
  local C = vec3(control - root)
  local R = vec3(0)

  -- Basis
  local bx = vec3(T):normalize()
  local by = (C - bx * (C:dot(bx))):normalize()
  local bz = vec3(bx):cross(by)

  -- Matrix from basis
  local transform = mat4(
    bx.x, by.x, bz.x, 0,
    bx.y, by.y, bz.y, 0,
    bx.z, by.z, bz.z, 0,
    0, 0, 0, 1
  ):transpose()

  local distance = #T
  local x = (distance + (lengths[1] ^ 2 - lengths[2] ^ 2) / distance) / 2
  local y = math.sqrt(lengths[1] ^ 2 - x ^ 2)
  local solution = vec4(x, y, 0, 1)
  return root + (transform * solution).xyz
end

function lovr.load()
  boneLengths = { .3, .3 }
  root = lovr.math.newVec3(-.2, 1.5, -.5)
  target = lovr.math.newVec3(.2, 1.5, -.7)
  control = lovr.math.newVec3(0, 1.8, -.6)
  pointSize = .04
  drags = {}
end

function lovr.update(dt)
  -- Allow hands to drag any of the points
  local points = { root, target, control }
  for i, hand in ipairs(lovr.headset.getHands()) do
    local handPosition = vec3(lovr.headset.getPosition(hand))

    if lovr.headset.wasPressed(hand, 'trigger') then
      for j, point in ipairs(points) do
        if handPosition:distance(point) < pointSize then
          drags[hand] = point
        end
      end
    elseif lovr.headset.wasReleased(hand, 'trigger') then
      drags[hand] = nil
    end

    if drags[hand] then
      drags[hand]:set(handPosition)
    end
  end
end

function lovr.draw()

  -- Draw the joints and the control point
  lovr.graphics.setColor(0xff80ff)
  lovr.graphics.sphere(root, pointSize / 2)
  lovr.graphics.sphere(target, pointSize / 2)
  lovr.graphics.setColor(0x80ffff)
  lovr.graphics.sphere(control, pointSize / 2)

  -- Draw the hand
  lovr.graphics.setColor(0xffffff)
  for _, hand in ipairs({ 'left', 'right' }) do
    if lovr.headset.isTracked(hand) then
      lovr.graphics.cube('fill', mat4(lovr.headset.getPose(hand)):scale(.01))
    end
  end

  -- Draw a line from the root to the result from the IK solver, then to the target
  lovr.graphics.line(root, solve(root, target, control, boneLengths), target)
end
