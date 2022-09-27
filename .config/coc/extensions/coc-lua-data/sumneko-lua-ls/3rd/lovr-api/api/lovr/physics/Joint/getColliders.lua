return {
  summary = 'Get the Colliders the Joint is attached to.',
  description = [[
    Returns the Colliders the Joint is attached to.  All Joints are attached to two colliders.
  ]],
  arguments = {},
  returns = {
    {
      name = 'colliderA',
      type = 'Collider',
      description = 'The first Collider.'
    },
    {
      name = 'colliderB',
      type = 'Collider',
      description = 'The second Collider.'
    }
  }
}
