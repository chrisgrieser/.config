return {
  summary = 'Get the number of nodes in the Model.',
  description = 'Returns the number of nodes (bones) in the Model.',
  arguments = {},
  returns = {
    {
      name = 'count',
      type = 'number',
      description = 'The number of nodes in the Model.'
    }
  },
  related = {
    'Model:getNodeName',
    'Model:getNodePose',
    'Model:pose'
  }
}
