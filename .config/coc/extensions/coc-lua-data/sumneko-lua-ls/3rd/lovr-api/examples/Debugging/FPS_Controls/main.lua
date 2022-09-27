lovr.keyboard = require 'lovr-keyboard'
lovr.mouse = require 'lovr-mouse'

function lovr.load()
  lovr.mouse.setRelativeMode(true)

  camera = {
    transform = lovr.math.newMat4(),
    position = lovr.math.newVec3(),
    movespeed = 10,
    pitch = 0,
    yaw = 0
  }
end

function lovr.update(dt)
  local velocity = vec4()

  if lovr.keyboard.isDown('w', 'up') then
    velocity.z = -1
  elseif lovr.keyboard.isDown('s', 'down') then
    velocity.z = 1
  end

  if lovr.keyboard.isDown('a', 'left') then
    velocity.x = -1
  elseif lovr.keyboard.isDown('d', 'right') then
    velocity.x = 1
  end

  if #velocity > 0 then
    velocity:normalize()
    velocity:mul(camera.movespeed * dt)
    camera.position:add(camera.transform:mul(velocity).xyz)
  end

  camera.transform:identity()
  camera.transform:translate(0, 1.7, 0)
  camera.transform:translate(camera.position)
  camera.transform:rotate(camera.yaw, 0, 1, 0)
  camera.transform:rotate(camera.pitch, 1, 0, 0)
end

function lovr.draw()
  lovr.graphics.push()
  lovr.graphics.transform(mat4(camera.transform):invert())
  lovr.graphics.setColor(0xff0000)
  lovr.graphics.cube('fill', 0, 1.7, -3, .5, lovr.timer.getTime())
  lovr.graphics.setColor(0xffffff)
  lovr.graphics.plane('fill', 0, 0, 0, 10, 10, math.pi / 2, 1, 0, 0)
  lovr.graphics.pop()
end

function lovr.mousemoved(x, y, dx, dy)
  camera.pitch = camera.pitch - dy * .001
  camera.yaw = camera.yaw - dx * .001
end

function lovr.keypressed(key)
  if key == 'escape' then
    lovr.event.quit()
  end
end
