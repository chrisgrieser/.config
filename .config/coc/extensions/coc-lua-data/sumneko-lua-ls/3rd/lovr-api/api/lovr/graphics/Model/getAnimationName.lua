return {
  summary = 'Get the name of an animation in the Model.',
  description = 'Returns the name of one of the animations in the Model.',
  arguments = {
    {
      name = 'index',
      type = 'number',
      description = 'The index of the animation to get the name of.'
    }
  },
  returns = {
    {
      name = 'name',
      type = 'string',
      description = 'The name of the animation.'
    }
  },
  related = {
    'Model:getAnimationCount',
    'Model:getAnimationDuration',
    'Model:getMaterialName',
    'Model:getNodeName'
  }
}
