return {
  tag = 'modules',
  summary = 'Simulates 3D physics.',
  description = 'The `lovr.physics` module simulates 3D rigid body physics.',
  sections = {
    {
      name = 'Worlds',
      tag = 'world',
      description = [[
        A physics World holds all of the colliders and joints in the simulation.  It must be updated
        every frame using `World:update`, during which it will move all the colliders and resolve
        collisions between them.
      ]]
    },
    {
      name = 'Colliders',
      tag = 'colliders',
      description = [[
        Colliders are objects that represent a single rigid body in the physics simulation. They can
        have forces applied to them and collide with other colliders.
      ]]
    },
    {
      name = 'Shapes',
      tag = 'shapes',
      description = [[
        Shapes are 3D physics shapes that can be attached to colliders.  Shapes define, well, the
        shape of a Collider and how it collides with other objects.  Without any Shapes, a collider
        wouldn't collide with anything.

        Normally, you don't need to create Shapes yourself, as there are convenience functions on
        the World that will create colliders with shapes already attached.  However, you can attach
        multiple Shapes to a collider to create more complicated objects, and sometimes it can be
        useful to access the individual Shapes on a collider.
      ]]
    },
    {
      name = 'Joints',
      tag = 'joints',
      description = [[
        Joints are objects that constrain the movement of colliders in various ways.  Joints are
        attached to two colliders when they're created and usually have a concept of an "anchor",
        which is where the Joint is attached to relative to the colliders.  Joints can be used to
        create all sorts of neat things like doors, drawers, buttons, levers, or pendulums.
      ]]
    }
  }
}
