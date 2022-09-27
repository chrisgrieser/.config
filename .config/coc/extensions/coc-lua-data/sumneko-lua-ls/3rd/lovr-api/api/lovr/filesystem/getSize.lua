return {
  summary = 'Get the size of a file.',
  description = 'Returns the size of a file, in bytes.',
  arguments = {
    {
      name = 'file',
      type = 'string',
      description = 'The file.'
    }
  },
  returns = {
    {
      name = 'size',
      type = 'number',
      description = 'The size of the file, in bytes.'
    }
  },
  notes = 'If the file does not exist, an error is thrown.'
}
