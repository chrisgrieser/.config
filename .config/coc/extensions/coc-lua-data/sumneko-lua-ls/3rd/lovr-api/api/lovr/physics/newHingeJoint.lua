return {
  tag = 'joints',
  summary = 'Create a new HingeJoint.',
  description = 'Creates a new HingeJoint.',
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
      description = 'The x position of the hinge anchor, in world coordinates.'
    },
    {
      name = 'y',
      type = 'number',
      description = 'The y position of the hinge anchor, in world coordinates.'
    },
    {
      name = 'z',
      type = 'number',
      description = 'The z position of the hinge anchor, in world coordinates.'
    },
    {
      name = 'ax',
      type = 'number',
      description = 'The x component of the hinge axis.'
    },
    {
      name = 'ay',
      type = 'number',
      description = 'The y component of the hinge axis.'
    },
    {
      name = 'az',
      type = 'number',
      description = 'The z component of the hinge axis.'
    }
  },
  returns = {
    {
      name = 'hinge',
      type = 'HingeJoint',
      description = 'The new HingeJoint.'
    }
  },
  notes = [[
    A hinge joint constrains two colliders to allow rotation only around the hinge's axis.
  ]],
  related = {
    'lovr.physics.newBallJoint',
    'lovr.physics.newDistanceJoint',
    'lovr.physics.newSliderJoint'
  }
}
