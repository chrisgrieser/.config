return {
  summary = 'Get the response time of the joint.',
  description = [[
    Returns the response time of the joint.  See `World:setResponseTime` for more info.
  ]],
  arguments = {},
  returns = {
    {
      name = 'responseTime',
      type = 'number',
      description = 'The response time setting for the joint.'
    }
  },
  related = {
    'DistanceJoint:getResponseTime',
    'DistanceJoint:setResponseTime',
    'World:getResponseTime',
    'World:setResponseTime'
  }
}
