return {
  summary = 'Append content to the end of a file.',
  description = 'Appends content to the end of a file.',
  arguments = {
    filename = {
      type = 'string',
      description = 'The file to append to.'
    },
    content = {
      type = 'string',
      description = 'A string to write to the end of the file.'
    },
    blob = {
      type = 'Blob',
      description = 'A Blob containing data to append to the file.'
    }
  },
  returns = {
    bytes = {
      type = 'number',
      description = 'The number of bytes actually appended to the file.'
    }
  },
  variants = {
    {
      arguments = { 'filename', 'content' },
      returns = { 'bytes' }
    },
    {
      arguments = { 'filename', 'blob' },
      returns = { 'bytes' }
    }
  },
  notes = 'If the file does not exist, it is created.'
}
