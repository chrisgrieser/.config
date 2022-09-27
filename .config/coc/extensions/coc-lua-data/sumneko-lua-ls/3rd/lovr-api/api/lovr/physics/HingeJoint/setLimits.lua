return {
  summary = 'Set the HingeJoint\'s angle limits.',
  description = [[
    Sets the upper and lower limits of the hinge angle.  These should be between -π and π.
  ]],
  arguments = {
    {
      name = 'lower',
      type = 'number',
      description = 'The lower limit, in radians.'
    },
    {
      name = 'upper',
      type = 'number',
      description = 'The upper limit, in radians.'
    }
  },
  returns = {},
  related = {
    'HingeJoint:getAngle',
    'HingeJoint:getLowerLimit',
    'HingeJoint:setLowerLimit',
    'HingeJoint:getUpperLimit',
    'HingeJoint:setUpperLimit'
  }
}
