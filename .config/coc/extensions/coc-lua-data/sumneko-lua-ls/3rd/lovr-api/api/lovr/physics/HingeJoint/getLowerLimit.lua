return {
  summary = 'Get the HingeJoint\'s lower angle limit.',
  description = 'Returns the lower limit of the hinge angle.  This will be greater than -π.',
  arguments = {},
  returns = {
    {
      name = 'limit',
      type = 'number',
      description = 'The lower limit, in radians.'
    }
  },
  related = {
    'HingeJoint:getAngle',
    'HingeJoint:getUpperLimit',
    'HingeJoint:setUpperLimit',
    'HingeJoint:getLimits',
    'HingeJoint:setLimits'
  }
}
