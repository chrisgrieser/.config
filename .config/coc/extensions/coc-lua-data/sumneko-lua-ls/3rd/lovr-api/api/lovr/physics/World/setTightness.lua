return {
  tag = 'worldProperties',
  summary = 'Set the tightness of joints in the World.',
  description = [[
    Sets the tightness of joints in the World.

    The tightness controls how much force is applied to colliders connected by joints.  With a value
    of 0, no force will be applied and joints won't have any effect.  With a tightness of 1, a
    strong force will be used to try to keep the Colliders constrained.  A tightness larger than 1
    will overcorrect the joints, which can sometimes be desirable.  Negative tightness values are
    not supported.
  ]],
  arguments = {
    {
      name = 'tightness',
      type = 'number',
      description = 'The new tightness for the World.'
    }
  },
  returns = {},
  related = {
    'BallJoint:getTightness',
    'BallJoint:setTightness',
    'DistanceJoint:getTightness',
    'DistanceJoint:setTightness',
    'World:getResponseTime',
    'World:setResponseTime'
  }
}
