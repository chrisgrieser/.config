return {
  summary = 'Set the target distance of the DistanceJoint.',
  description = [[
    Sets the target distance for the DistanceJoint.  The joint tries to keep the Colliders this far
    apart.
  ]],
  arguments = {
    {
      name = 'distance',
      type = 'number',
      description = 'The new target distance.'
    }
  },
  returns = {}
}
