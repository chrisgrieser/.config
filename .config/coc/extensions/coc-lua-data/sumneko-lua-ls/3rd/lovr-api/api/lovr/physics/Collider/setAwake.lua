return {
  summary = 'Put the Collider to sleep or wake it up.',
  description = [[
    Manually puts the Collider to sleep or wakes it up.  You can do this if you know a Collider
    won't be touched for a while or if you need to it be active.
  ]],
  arguments = {
    {
      name = 'awake',
      type = 'boolean',
      description = 'Whether the Collider should be awake.'
    }
  },
  returns = {},
  related = {
    'World:isSleepingAllowed',
    'World:setSleepingAllowed',
    'Collider:isSleepingAllowed',
    'Collider:setSleepingAllowed'
  }
}
