return {
  summary = 'Check whether a path is a file.',
  description = 'Check if a path exists and is a file.',
  arguments = {
    {
      name = 'path',
      type = 'string',
      description = 'The path to check.'
    }
  },
  returns = {
    {
      name = 'isFile',
      type = 'boolean',
      description = 'Whether or not the path is a file.'
    }
  },
  related = {
    'lovr.filesystem.isDirectory'
  }
}
