return {
  summary = 'Set the SliderJoint\'s lower limit.',
  description = 'Sets the lower limit of the slider position.',
  arguments = {
    {
      name = 'limit',
      type = 'number',
      description = 'The lower limit.'
    }
  },
  returns = {},
  related = {
    'SliderJoint:getPosition',
    'SliderJoint:getUpperLimit',
    'SliderJoint:setUpperLimit',
    'SliderJoint:getLimits',
    'SliderJoint:setLimits'
  }
}
