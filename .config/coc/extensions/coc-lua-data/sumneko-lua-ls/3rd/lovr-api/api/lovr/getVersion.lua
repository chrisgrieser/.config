return {
  tag = 'version',
  summary = 'Get the current version.',
  description = 'Get the current major, minor, and patch version of LÖVR.',
  arguments = {},
  returns = {
    {
      name = 'major',
      type = 'number',
      description = 'The major version.'
    },
    {
      name = 'minor',
      type = 'number',
      description = 'The minor version.'
    },
    {
      name = 'patch',
      type = 'number',
      description = 'The patch number.'
    }
  }
}
