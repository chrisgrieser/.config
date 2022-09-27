return {
  summary = 'Get the location of the project source.',
  description = 'Get the absolute path of the project\'s source directory or archive.',
  arguments = {},
  returns = {
    {
      name = 'path',
      type = 'string',
      description = 'The absolute path of the project\'s source, or `nil` if it\'s unknown.'
    }
  }
}
