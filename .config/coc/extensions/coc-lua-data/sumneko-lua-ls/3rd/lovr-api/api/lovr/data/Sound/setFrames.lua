return {
  summary = 'Write frames to the Sound.',
  description = 'Writes frames to the Sound.',
  arguments = {
    t = {
      type = 'table',
      description = 'A table containing frames to write.'
    },
    blob = {
      type = 'Blob',
      description = 'A Blob containing frames to write.'
    },
    sound = {
      type = 'Sound',
      description = 'Another Sound to copy frames from.'
    },
    count = {
      type = 'number',
      default = 'nil',
      description = 'How many frames to write.  If nil, writes as many as possible.'
    },
    dstOffset = {
      type = 'number',
      default = '0',
      description = 'A frame offset to apply when writing the frames.'
    },
    srcOffset = {
      type = 'number',
      default = '0',
      description = 'A frame, byte, or index offset to apply when reading frames from the source.'
    }
  },
  returns = {
    count = {
      type = 'number',
      description = 'The number of frames written.'
    }
  },
  variants = {
    {
      arguments = { 't', 'count', 'dstOffset', 'srcOffset' },
      returns = { 'count' }
    },
    {
      arguments = { 'blob', 'count', 'dstOffset', 'srcOffset' },
      returns = { 'count' }
    },
    {
      arguments = { 'sound', 'count', 'dstOffset', 'srcOffset' },
      returns = { 'count' }
    }
  },
  example = {
    description = 'Generate a sine wave.',
    code = [[
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
    ]]
  }
}
