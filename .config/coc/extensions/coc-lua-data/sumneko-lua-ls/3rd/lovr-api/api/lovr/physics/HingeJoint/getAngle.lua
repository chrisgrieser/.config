return {
  summary = 'Get the angle of the HingeJoint.',
  description = [[
    Get the angle between the two colliders attached to the HingeJoint.  When the joint is created
    or when the anchor or axis is set, the current angle is the new "zero" angle.
  ]],
  arguments = {},
  returns = {
    {
      name = 'angle',
      type = 'number',
      description = 'The hinge angle, in radians.'
    }
  }
}
