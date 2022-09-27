return {
  summary = 'Set the response time of the joint.',
  description = 'Sets the response time of the joint.  See `World:setResponseTime` for more info.',
  arguments = {
    {
      name = 'responseTime',
      type = 'number',
      description = 'The new response time setting for the joint.'
    }
  },
  returns = {},
  related = {
    'DistanceJoint:getResponseTime',
    'DistanceJoint:setResponseTime',
    'World:getResponseTime',
    'World:setResponseTime'
  }
}
