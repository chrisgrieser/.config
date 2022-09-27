return {
  summary = 'Set the SliderJoint\'s upper limit.',
  description = 'Sets the upper limit of the slider position.',
  arguments = {
    {
      name = 'limit',
      type = 'number',
      description = 'The upper limit.'
    }
  },
  returns = {},
  related = {
    'SliderJoint:getPosition',
    'SliderJoint:getLowerLimit',
    'SliderJoint:setLowerLimit',
    'SliderJoint:getLimits',
    'SliderJoint:setLimits'
  }
}
