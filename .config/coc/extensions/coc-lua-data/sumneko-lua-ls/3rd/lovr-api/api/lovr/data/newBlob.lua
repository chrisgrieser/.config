return {
  summary = 'Create a new Blob.',
  description = 'Creates a new Blob.',
  arguments = {
    size = {
      type = 'number',
      description = [[
        The amount of data to allocate for the Blob, in bytes.  All of the bytes will be filled with
        zeroes.
      ]]
    },
    contents = {
      type = 'string',
      description = 'A string to use for the Blob\'s contents.'
    },
    source = {
      type = 'Blob',
      description = 'A Blob to copy the contents from.'
    },
    name = {
      type = 'string',
      default = [['']],
      description = 'A name for the Blob (used in error messages)',
    }
  },
  returns = {
    blob = {
      type = 'Blob',
      description = 'The new Blob.'
    }
  },
  variants = {
    {
      arguments = { 'size', 'name' },
      returns = { 'blob' }
    },
    {
      arguments = { 'contents', 'name' },
      returns = { 'blob' }
    },
    {
      arguments = { 'source', 'name' },
      returns = { 'blob' }
    }
  },
  related = {
    'lovr.filesystem.newBlob'
  }
}
