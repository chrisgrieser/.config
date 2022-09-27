function lovr.load()
  local length = 1
  local rate = 48000
  local frames = length * rate
  local frequency = 440
  local volume = 1.0

  sound = lovr.data.newSound(frames, 'f32', 'stereo', rate)

  local data = {}
  for i = 1, frames do
    local amplitude = math.sin((i - 1) * frequency / rate * (2 * math.pi)) * volume
    data[2 * i - 1] = amplitude
    data[2 * i - 0] = amplitude
  end

  sound:setFrames(data)

  source = lovr.audio.newSource(sound)
  source:setLooping(true)
  source:play()
end
