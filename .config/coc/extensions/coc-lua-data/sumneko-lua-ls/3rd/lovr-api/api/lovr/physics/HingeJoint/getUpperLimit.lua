return {
  summary = 'Get the HingeJoint\'s upper angle limit.',
  description = 'Returns the upper limit of the hinge angle.  This will be less than π.',
  arguments = {},
  returns = {
    {
      name = 'limit',
      type = 'number',
      description = 'The upper limit, in radians.'
    }
  },
  related = {
    'HingeJoint:getAngle',
    'HingeJoint:getLowerLimit',
    'HingeJoint:setLowerLimit',
    'HingeJoint:getLimits',
    'HingeJoint:setLimits'
  }
}
