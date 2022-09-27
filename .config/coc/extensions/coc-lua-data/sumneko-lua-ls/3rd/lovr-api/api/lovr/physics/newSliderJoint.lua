return {
  tag = 'joints',
  summary = 'Create a new SliderJoint.',
  description = 'Creates a new SliderJoint.',
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
      name = 'ax',
      type = 'number',
      description = 'The x component of the slider axis.'
    },
    {
      name = 'ay',
      type = 'number',
      description = 'The y component of the slider axis.'
    },
    {
      name = 'az',
      type = 'number',
      description = 'The z component of the slider axis.'
    }
  },
  returns = {
    {
      name = 'slider',
      type = 'SliderJoint',
      description = 'The new SliderJoint.'
    }
  },
  notes = [[
    A slider joint constrains two colliders to only allow movement along the slider's axis.
  ]],
  related = {
    'lovr.physics.newBallJoint',
    'lovr.physics.newDistanceJoint',
    'lovr.physics.newHingeJoint'
  }
}
