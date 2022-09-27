return {
  summary = 'A ball and socket joint.',
  description = [[
    A BallJoint is a type of `Joint` that acts like a ball and socket between two colliders.  It
    allows the colliders to rotate freely around an anchor point, but does not allow the colliders'
    distance from the anchor point to change.
  ]],
  extends = 'Joint',
  constructors = {
    'lovr.physics.newBallJoint'
  },
  related = {
    'Collider'
  }
}
