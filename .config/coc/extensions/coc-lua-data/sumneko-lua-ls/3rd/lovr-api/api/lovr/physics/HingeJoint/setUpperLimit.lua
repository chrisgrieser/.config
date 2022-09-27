return {
  summary = 'Set the HingeJoint\'s upper angle limit.',
  description = 'Sets the upper limit of the hinge angle.  This should be less than π.',
  arguments = {
    {
      name = 'limit',
      type = 'number',
      description = 'The upper limit, in radians.'
    }
  },
  returns = {},
  related = {
    'HingeJoint:getAngle',
    'HingeJoint:getLowerLimit',
    'HingeJoint:setLowerLimit',
    'HingeJoint:getLimits',
    'HingeJoint:setLimits'
  }
}
