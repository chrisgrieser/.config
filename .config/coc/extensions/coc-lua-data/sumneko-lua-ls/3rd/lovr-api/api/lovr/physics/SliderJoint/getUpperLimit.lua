return {
  summary = 'Get the SliderJoint\'s upper limit.',
  description = 'Returns the upper limit of the slider position.',
  arguments = {},
  returns = {
    {
      name = 'limit',
      type = 'number',
      description = 'The upper limit.'
    }
  },
  related = {
    'SliderJoint:getPosition',
    'SliderJoint:getLowerLimit',
    'SliderJoint:setLowerLimit',
    'SliderJoint:getLimits',
    'SliderJoint:setLimits'
  }
}
