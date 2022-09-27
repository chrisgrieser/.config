return {
  tag = 'joints',
  summary = 'Create a new BallJoint.',
  description = 'Creates a new BallJoint.',
  arguments = {
    {
      name = 'colliderA',
      type = 'Collider',
      description = 'The first collider to attach the Joint to.'
    },
    {
      name = 'colliderB',
      type = 'Collider',
      description = 'The second collider to attach the Joint to.'
    },
    {
      name = 'x',
      type = 'number',
      description = 'The x position of the joint anchor point, in world coordinates.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y position of the joint anchor point, in world coordinates.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z position of the joint anchor point, in world coordinates.'
    }
  },
  returns = {
    {
      name = 'ball',
      type = 'BallJoint',
      description = 'The new BallJoint.'
    }
  },
  notes = [[
    A ball joint is like a ball and socket between the two colliders.  It tries to keep the distance
    between the colliders and the anchor position the same, but does not constrain the angle between
    them.
  ]],
  related = {
    'lovr.physics.newDistanceJoint',
    'lovr.physics.newHingeJoint',
    'lovr.physics.newSliderJoint'
  }
}
