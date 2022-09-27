return {
  summary = 'Set the SliderJoint\'s limits.',
  description = 'Sets the upper and lower limits of the slider position.',
  arguments = {
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
  returns = {},
  related = {
    'SliderJoint:getPosition',
    'SliderJoint:getLowerLimit',
    'SliderJoint:setLowerLimit',
    'SliderJoint:getUpperLimit',
    'SliderJoint:setUpperLimit'
  }
}
