return {
  summary = 'Get the current working directory.',
  description = [[
    Returns the absolute path of the working directory.  Usually this is where the executable was
    started from.
  ]],
  arguments = {},
  returns = {
    {
      name = 'path',
      type = 'string',
      description = 'The current working directory, or `nil` if it\'s unknown.'
    }
  }
}
