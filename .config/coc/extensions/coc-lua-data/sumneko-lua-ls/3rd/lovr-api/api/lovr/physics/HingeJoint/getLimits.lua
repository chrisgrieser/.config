return {
  summary = 'Get the HingeJoint\'s angle limits.',
  description = [[
    Returns the upper and lower limits of the hinge angle.  These will be between -π and π.
  ]],
  arguments = {},
  returns = {
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
  related = {
    'HingeJoint:getAngle',
    'HingeJoint:getLowerLimit',
    'HingeJoint:setLowerLimit',
    'HingeJoint:getUpperLimit',
    'HingeJoint:setUpperLimit'
  }
}
