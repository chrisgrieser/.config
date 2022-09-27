return {
  summary = 'Set whether the Collider is allowed to sleep.',
  description = 'Sets whether the Collider is allowed to sleep.',
  arguments = {
    {
      name = 'allowed',
      type = 'boolean',
      description = 'Whether the Collider can go to sleep.'
    }
  },
  returns = {},
  notes = [[
    If sleeping is enabled, the simulation will put the Collider to sleep if it hasn't moved in a
    while. Sleeping colliders don't impact the physics simulation, which makes updates more
    efficient and improves physics performance.  However, the physics engine isn't perfect at waking
    up sleeping colliders and this can lead to bugs where colliders don't react to forces or
    collisions properly.

    It is possible to set the default value for new colliders using `World:setSleepingAllowed`.

    Colliders can be manually put to sleep or woken up using `Collider:setAwake`.
  ]],
  related = {
    'World:isSleepingAllowed',
    'World:setSleepingAllowed',
    'Collider:isAwake',
    'Collider:setAwake'
  }
}
