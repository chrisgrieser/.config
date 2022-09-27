return {
  summary = 'Set the Collider\'s user data.',
  description = 'Associates a custom value with the Collider.',
  arguments = {
    {
      name = 'data',
      type = '*',
      description = 'The custom value to associate with the Collider.'
    }
  },
  returns = {},
  notes = 'User data can be useful to identify the Collider in callbacks.'
}
