return {
  summary = 'Get the SliderJoint\'s lower limit.',
  description = 'Returns the lower limit of the slider position.',
  arguments = {},
  returns = {
    {
      name = 'limit',
      type = 'number',
      description = 'The lower limit.'
    }
  },
  related = {
    'SliderJoint:getPosition',
    'SliderJoint:getUpperLimit',
    'SliderJoint:setUpperLimit',
    'SliderJoint:getLimits',
    'SliderJoint:setLimits'
  }
}
