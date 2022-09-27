return {
  summary = 'Get the name of a material in the Model.',
  description = 'Returns the name of one of the materials in the Model.',
  arguments = {
    {
      name = 'index',
      type = 'number',
      description = 'The index of the material to get the name of.'
    }
  },
  returns = {
    {
      name = 'name',
      type = 'string',
      description = 'The name of the material.'
    }
  },
  related = {
    'Model:getMaterialCount',
    'Model:getAnimationName',
    'Model:getNodeName'
  }
}
