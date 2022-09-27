return {
  summary = 'Get the SliderJoint\'s limits.',
  description = 'Returns the upper and lower limits of the slider position.',
  arguments = {},
  returns = {
    {
      name = 'lower',
      type = 'number',
      description = 'The lower limit.'
    },
    {
      name = 'upper',
      type = 'number',
      description = 'The upper limit.'
    }
  },
  related = {
    'SliderJoint:getPosition',
    'SliderJoint:getLowerLimit',
    'SliderJoint:setLowerLimit',
    'SliderJoint:getUpperLimit',
    'SliderJoint:setUpperLimit'
  }
}
