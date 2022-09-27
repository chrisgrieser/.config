return {
  summary = 'Check whether a path is a directory.',
  description = 'Check if a path exists and is a directory.',
  arguments = {
    {
      name = 'path',
      type = 'string',
      description = 'The path to check.'
    }
  },
  returns = {
    {
      name = 'isDirectory',
      type = 'boolean',
      description = 'Whether or not the path is a directory.'
    }
  },
  related = {
    'lovr.filesystem.isFile'
  }
}
