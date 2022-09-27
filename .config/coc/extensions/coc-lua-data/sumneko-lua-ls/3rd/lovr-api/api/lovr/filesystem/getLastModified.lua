return {
  summary = 'Get the modification time of a file.',
  description = 'Returns when a file was last modified, since some arbitrary time in the past.',
  arguments = {
    {
      name = 'path',
      type = 'string',
      description = 'The file to check.'
    }
  },
  returns = {
    {
      name = 'time',
      type = 'number',
      description = 'The modification time of the file, in seconds, or `nil` if it\'s unknown.'
    }
  }
}
