return {
  summary = 'Read frames from the Sound.',
  description = 'Reads frames from the Sound into a table, Blob, or another Sound.',
  arguments = {
    t = {
      type = 'table',
      description = 'An existing table to read frames into.'
    },
    blob = {
      type = 'Blob',
      description = 'A Blob to read frames into.'
    },
    sound = {
      type = 'Sound',
      description = 'Another Sound to copy frames into.'
    },
    count = {
      type = 'number',
      default = 'nil',
      description = [[
        The number of frames to read.  If nil, reads as many frames as possible.

        Compressed sounds will automatically be decoded.

        Reading from a stream will ignore the source offset and read the oldest frames.
      ]]
    },
    srcOffset = {
      type = 'number',
      default = '0',
      description = 'A frame offset to apply to the sound when reading frames.'
    },
    dstOffset = {
      type = 'number',
      default = '0',
      description = [[
        An offset to apply to the destination when writing frames (indices for tables, bytes for
        Blobs, frames for Sounds).
      ]]
    }
  },
  returns = {
    t = {
      type = 'table',
      description = 'A table containing audio frames.'
    },
    count = {
      type = 'number',
      description = 'The number of frames read.'
    }
  },
  variants = {
    {
      arguments = { 'count', 'srcOffset' },
      returns = { 't', 'count' }
    },
    {
      arguments = { 't', 'count', 'srcOffset', 'dstOffset' },
      returns = { 't', 'count' }
    },
    {
      arguments = { 'blob', 'count', 'srcOffset', 'dstOffset' },
      returns = { 'count' }
    },
    {
      arguments = { 'sound', 'count', 'srcOffset', 'dstOffset' },
      returns = { 'count' }
    }
  }
}
