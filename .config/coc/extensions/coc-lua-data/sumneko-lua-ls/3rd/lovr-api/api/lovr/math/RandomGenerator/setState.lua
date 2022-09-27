return {
  summary = 'Set the state of the RandomGenerator.',
  description = [[
    Sets the state of the RandomGenerator, as previously obtained using `RandomGenerator:getState`.
    This can be used to reliably restore a previous state of the generator.
  ]],
  arguments = {
    {
      name = 'state',
      type = 'string',
      description = 'The serialized state.'
    }
  },
  returns = {},
  notes = [[
    The seed represents the starting state of the RandomGenerator, whereas the state represents the
    current state of the generator.
  ]]
}
