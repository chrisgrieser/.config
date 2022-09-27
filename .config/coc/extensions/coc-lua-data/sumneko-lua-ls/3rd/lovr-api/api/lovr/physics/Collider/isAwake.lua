return {
  summary = 'Check if the Collider is awake.',
  description = 'Returns whether the Collider is currently awake.',
  arguments = {},
  returns = {
    {
      name = 'awake',
      type = 'boolean',
      description = 'Whether the Collider is awake.'
    }
  },
  related = {
    'World:isSleepingAllowed',
    'World:setSleepingAllowed',
    'Collider:isSleepingAllowed',
    'Collider:setSleepingAllowed'
  }
}
