return {
  summary = 'Get the anchor points of the BallJoint.',
  description = [[
    Returns the anchor points of the BallJoint, in world coordinates.  The first point is the anchor
    on the first collider, and the second point is on the second collider.  The joint tries to keep
    these points the same, but they may be different if the joint is forced apart by some other
    means.
  ]],
  arguments = {},
  returns = {
    {
      name = 'x1',
      type = 'number',
      description = 'The x coordinate of the first anchor point, in world coordinates.'
    },
    {
      name = 'y1',
      type = 'number',
      description = 'The y coordinate of the first anchor point, in world coordinates.'
    },
    {
      name = 'z1',
      type = 'number',
      description = 'The z coordinate of the first anchor point, in world coordinates.'
    },
    {
      name = 'x2',
      type = 'number',
      description = 'The x coordinate of the second anchor point, in world coordinates.'
    },
    {
      name = 'y2',
      type = 'number',
      description = 'The y coordinate of the second anchor point, in world coordinates.'
    },
    {
      name = 'z2',
      type = 'number',
      description = 'The z coordinate of the second anchor point, in world coordinates.'
    }
  }
}
