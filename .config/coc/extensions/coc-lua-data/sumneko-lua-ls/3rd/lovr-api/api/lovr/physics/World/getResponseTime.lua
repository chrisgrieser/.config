return {
  tag = 'worldProperties',
  summary = 'Get the response time of the World.',
  description = [[
    Returns the response time factor of the World.

    The response time controls how relaxed collisions and joints are in the physics simulation, and
    functions similar to inertia.  A low response time means collisions are resolved quickly, and
    higher values make objects more spongy and soft.

    The value can be any positive number.  It can be changed on a per-joint basis for
    `DistanceJoint` and `BallJoint` objects.
  ]],
  arguments = {},
  returns = {
    {
      name = 'responseTime',
      type = 'number',
      description = 'The response time setting for the World.'
    }
  },
  related = {
    'BallJoint:getResponseTime',
    'BallJoint:setResponseTime',
    'DistanceJoint:getResponseTime',
    'DistanceJoint:setResponseTime',
    'World:getTightness',
    'World:setTightness'
  }
}
