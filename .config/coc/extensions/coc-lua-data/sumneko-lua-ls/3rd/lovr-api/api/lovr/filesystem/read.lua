return {
  summary = 'Read a file.',
  description = 'Read the contents of a file.',
  arguments = {
    {
      name = 'filename',
      type = 'string',
      description = 'The name of the file to read.'
    },
    {
      name = 'bytes',
      type = 'number',
      default = '-1',
      description = 'The number of bytes to read (if -1, all bytes will be read).'
    }
  },
  returns = {
    {
      name = 'contents',
      type = 'string',
      description = 'The contents of the file.'
    },
    {
      name = 'bytes',
      type = 'number',
      description = 'The number of bytes read from the file.'
    }
  },
  notes = 'If the file does not exist or cannot be read, nil is returned.'
}
