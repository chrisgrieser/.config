return {
  summary = 'Steps the internal clock.',
  description = [[
    Steps the timer, returning the new delta time.  This is called automatically in `lovr.run` and
    it's used to calculate the new `dt` to pass to `lovr.update`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'delta',
      type = 'number',
      description = 'The amount of time since the last call to this function, in seconds.'
    }
  }
}
