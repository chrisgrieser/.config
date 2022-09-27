return {
  summary = 'Get the label of the Blob.',
  description = [[
    Returns the filename the Blob was loaded from, or the custom name given to it when it was
    created.  This label is also used in error messages.
  ]],
  arguments = {},
  returns = {
    {
      name = 'name',
      type = 'string',
      description = 'The name of the Blob.'
    }
  }
}
