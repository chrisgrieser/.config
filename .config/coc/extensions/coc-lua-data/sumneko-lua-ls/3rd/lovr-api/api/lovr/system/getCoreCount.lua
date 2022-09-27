return {
  summary = 'Get the number of logical cores.',
  description = 'Returns the number of logical cores on the system.',
  arguments = {},
  returns = {
    {
      name = 'cores',
      type = 'number',
      description = 'The number of logical cores on the system.'
    }
  },
  related = {
    'lovr.thread'
  }
}
