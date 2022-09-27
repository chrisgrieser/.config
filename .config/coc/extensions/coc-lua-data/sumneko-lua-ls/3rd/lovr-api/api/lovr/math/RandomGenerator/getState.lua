return {
  summary = 'Get the current state of the RandomGenerator.',
  description = [[
    Returns the current state of the RandomGenerator.  This can be used with
    `RandomGenerator:setState` to reliably restore a previous state of the generator.
  ]],
  arguments = {},
  returns = {
    {
      name = 'state',
      type = 'string',
      description = 'The serialized state.'
    }
  },
  notes = [[
    The seed represents the starting state of the RandomGenerator, whereas the state represents the
    current state of the generator.
  ]]
}
