return {
  tag = 'joints',
  summary = 'Create a new DistanceJoint.',
  description = 'Creates a new DistanceJoint.',
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
      name = 'x1',
      type = 'number',
      description = 'The x position of the first anchor point, in world coordinates.'
    },
    {
      name = 'y1',
      type = 'number',
      description = 'The y position of the first anchor point, in world coordinates.'
    },
    {
      name = 'z1',
      type = 'number',
      description = 'The z position of the first anchor point, in world coordinates.'
    },
    {
      name = 'x2',
      type = 'number',
      description = 'The x position of the second anchor point, in world coordinates.'
    },
    {
      name = 'y2',
      type = 'number',
      description = 'The y position of the second anchor point, in world coordinates.'
    },
    {
      name = 'z2',
      type = 'number',
      description = 'The z position of the second anchor point, in world coordinates.'
    }
  },
  returns = {
    {
      name = 'joint',
      type = 'DistanceJoint',
      description = 'The new DistanceJoint.'
    }
  },
  notes = [[
    A distance joint tries to keep the two colliders a fixed distance apart.  The distance is
    determined by the initial distance between the anchor points.  The joint allows for rotation on
    the anchor points.
  ]],
  related = {
    'lovr.physics.newBallJoint',
    'lovr.physics.newHingeJoint',
    'lovr.physics.newSliderJoint'
  }
}
