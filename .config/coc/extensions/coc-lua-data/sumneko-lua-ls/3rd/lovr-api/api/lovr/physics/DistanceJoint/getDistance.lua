return {
  summary = 'Get the target distance of the DistanceJoint.',
  description = [[
    Returns the target distance for the DistanceJoint.  The joint tries to keep the Colliders this
    far apart.
  ]],
  arguments = {},
  returns = {
    {
      name = 'distance',
      type = 'number',
      description = 'The target distance.'
    }
  }
}
