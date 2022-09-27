function lovr.load()
  source = lovr.audio.newSource('sine.wav')
  source:setLooping(true)
  source:play()
  muted = false
end

function lovr.update()
  if lovr.headset.wasPressed('left', 'trigger') or lovr.headset.wasPressed('right', 'trigger') then
    muted = not muted
    lovr.audio.setVolume(muted and 0 or 1)
  end
end

function lovr.draw()
  lovr.graphics.print(muted and 'Muted' or 'Unmuted', 0, 1.7, -1, .1)
  lovr.graphics.print('Press trigger to toggle mute', 0, 1.7 - lovr.graphics.getFont():getHeight() * .2, -1, .1)
end
