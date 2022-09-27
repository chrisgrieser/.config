return {
  summary = 'Get the pose of a single node.',
  description = 'Returns the pose of a single node in the Model in a given `CoordinateSpace`.',
  arguments = {
    name = {
      type = 'string',
      description = 'The name of the node.'
    },
    index = {
      type = 'number',
      description = 'The node index.'
    },
    space = {
      type = 'CoordinateSpace',
      default = [['global']],
      description = [[
        Whether the pose should be returned relative to the node's parent or relative to the root
        node of the Model.
      ]]
    }
  },
  returns = {
    x = {
      type = 'number',
      description = 'The x position of the node.'
    },
    y = {
      type = 'number',
      description = 'The y position of the node.'
    },
    z = {
      type = 'number',
      description = 'The z position of the node.'
    },
    angle = {
      type = 'number',
      description = 'The number of radians the node is rotated around its rotational axis.'
    },
    ax = {
      type = 'number',
      description = 'The x component of the axis of rotation.'
    },
    ay = {
      type = 'number',
      description = 'The y component of the axis of rotation.'
    },
    az = {
      type = 'number',
      description = 'The z component of the axis of rotation.'
    }
  },
  variants = {
    {
      arguments = { 'name', 'space' },
      returns = { 'x', 'y', 'z', 'angle', 'ax', 'ay', 'az' }
    },
    {
      arguments = { 'index', 'space' },
      returns = { 'x', 'y', 'z', 'angle', 'ax', 'ay', 'az' }
    }
  },
  notes = [[
    For skinned nodes to render correctly, use a Shader created with the `animated` flag set to
    `true`.  See `lovr.graphics.newShader` for more.
  ]],
  related = {
    'Model:pose',
    'Model:animate',
    'Model:getNodeName',
    'Model:getNodeCount'
  }
}
