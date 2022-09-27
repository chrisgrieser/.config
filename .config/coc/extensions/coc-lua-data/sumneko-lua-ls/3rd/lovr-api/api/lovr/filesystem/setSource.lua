return {
  summary = 'Set the project source.',
  description = [[
    Sets the location of the project's source.  This can only be done once, and is usually done
    internally.
  ]],
  arguments = {
    {
      name = 'identity',
      type = 'string',
      description = 'The path containing the project\'s source.'
    }
  },
  returns = {}
}
