return {
  summary = 'Time units for sound samples.',
  description = [[
    When figuring out how long a Source is or seeking to a specific position in the sound file,
    units can be expressed in terms of seconds or in terms of frames.  A frame is one set of samples
    for each channel (one sample for mono, two samples for stereo).
  ]],
  values = {
    {
      name = 'seconds',
      description = 'Seconds.'
    },
    {
      name = 'frames',
      description = 'Frames.'
    }
  }
}
