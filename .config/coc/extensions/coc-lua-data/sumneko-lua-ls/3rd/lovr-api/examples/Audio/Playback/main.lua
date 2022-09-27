-- Play a continuous sine wav
function lovr.load()
  source = lovr.audio.newSource('sine.wav')
  source:setLooping(true)
  source:play()
end

-- Oscillate volume
function lovr.update()
  local time = lovr.timer.getTime()
  local average, spread, speed = .5, .25, 4
  local volume = average + math.sin(time * speed) * spread
  source:setVolume(volume)
end
