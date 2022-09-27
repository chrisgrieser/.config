return {
  summary = 'Different data types for samples in a Sound.',
  description = 'Sounds can store audio samples as 16 bit integers or 32 bit floats.',
  values = {
    {
      name = 'f32',
      description = '32 bit floating point samples (between -1.0 and 1.0).'
    },
    {
      name = 'i16',
      description = '16 bit integer samples (between -32768 and 32767).'
    }
  },
  related = {
    'lovr.data.newSound',
    'Sound:getFormat'
  }
}
