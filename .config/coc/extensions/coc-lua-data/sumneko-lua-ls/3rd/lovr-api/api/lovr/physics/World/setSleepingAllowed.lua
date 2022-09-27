return {
  tag = 'worldProperties',
  summary = 'Set whether colliders can go to sleep.',
  description = 'Sets whether colliders can go to sleep in the World.',
  arguments = {
    {
      name = 'allowed',
      type = 'boolean',
      description = 'Whether colliders can sleep.'
    }
  },
  returns = {},
  notes = [[
    If sleeping is enabled, the World will try to detect colliders that haven't moved for a while
    and put them to sleep.  Sleeping colliders don't impact the physics simulation, which makes
    updates more efficient and improves physics performance.  However, the physics engine isn't
    perfect at waking up sleeping colliders and this can lead to bugs where colliders don't react to
    forces or collisions properly.

    This can be set on individual colliders.

    Colliders can be manually put to sleep or woken up using `Collider:setAwake`.
  ]],
  related = {
    'Collider:isSleepingAllowed',
    'Collider:setSleepingAllowed',
    'Collider:isAwake',
    'Collider:setAwake'
  }
}
