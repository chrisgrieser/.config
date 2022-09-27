return {
  summary = 'Check if the Collider is kinematic.',
  description = 'Returns whether the Collider is kinematic.',
  arguments = {},
  returns = {
    {
      name = 'kinematic',
      type = 'boolean',
      description = 'Whether the Collider is kinematic.'
    }
  },
  notes = [[
    Kinematic colliders behave as though they have infinite mass, ignoring external forces like
    gravity, joints, or collisions (though non-kinematic colliders will collide with them). They can
    be useful for static objects like floors or walls.
  ]]
}
