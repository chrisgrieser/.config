return {
  summary = 'Set the pose of a single node, or clear the pose.',
  description = [[
    Applies a pose to a single node of the Model.  The input pose is assumed to be relative to the
    pose of the node's parent.  This is useful for applying inverse kinematics (IK) to a chain of
    bones in a skeleton.

    The alpha parameter can be used to mix between the node's current pose and the input pose.
  ]],
  arguments = {
    name = {
      type = 'string',
      description = 'The name of the node.'
    },
    index = {
      type = 'number',
      description = 'The node index.'
    },
    x = {
      type = 'number',
      description = 'The x position.'
    },
    y = {
      type = 'number',
      description = 'The y position.'
    },
    z = {
      type = 'number',
      description = 'The z position.'
    },
    angle = {
      type = 'number',
      description = 'The angle of rotation around the axis, in radians.'
    },
    ax = {
      type = 'number',
      description = 'The x component of the rotation axis.'
    },
    ay = {
      type = 'number',
      description = 'The y component of the rotation axis.'
    },
    az = {
      type = 'number',
      description = 'The z component of the rotation axis.'
    },
    alpha = {
      type = 'number',
      default = '1',
      description = 'How much of the pose to mix in, from 0 to 1.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'name', 'x', 'y', 'z', 'angle', 'ax', 'ay', 'az', 'alpha' },
      returns = {}
    },
    {
      arguments = { 'index', 'x', 'y', 'z', 'angle', 'ax', 'ay', 'az', 'alpha' },
      returns = {}
    },
    {
      description = 'Clear the pose of the Model.',
      arguments = {},
      returns = {}
    }
  },
  notes = [[
    For skinned nodes to render correctly, use a Shader created with the `animated` flag set to
    `true`.  See `lovr.graphics.newShader` for more.
  ]],
  related = {
    'Model:getNodePose',
    'Model:animate',
    'Model:getNodeName',
    'Model:getNodeCount'
  }
}
