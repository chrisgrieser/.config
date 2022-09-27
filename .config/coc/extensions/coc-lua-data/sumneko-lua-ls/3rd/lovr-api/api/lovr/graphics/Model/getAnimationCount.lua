return {
  summary = 'Get the number of animations in the Model.',
  description = 'Returns the number of animations in the Model.',
  arguments = {},
  returns = {
    {
      name = 'count',
      type = 'number',
      description = 'The number of animations in the Model.'
    }
  },
  related = {
    'Model:getAnimationName',
    'Model:getAnimationDuration',
    'Model:animate'
  }
}
