return {
  summary = 'An independent physics simulation.',
  description = [[
    A World is an object that holds the colliders, joints, and shapes in a physics simulation.
  ]],
  constructor = 'lovr.physics.newWorld',
  sections = {
    {
      name = 'Basics',
      tag = 'worldBasics'
    },
    {
      name = 'Colliders',
      tag = 'colliders',
      description = [[
        The following functions add Colliders to the World.  `World:newCollider` adds an "empty"
        Collider without any Shapes attached, whereas the other functions are shortcut functions to
        add Colliders with Shapes already attached to them.
      ]]
    },
    {
      name = 'Properties',
      tag = 'worldProperties',
      description = [[
        The following functions are global properties of the simulation that apply to all new
        Colliders.
      ]]
    },
    {
      name = 'Collision',
      tag = 'worldCollision',
      description = [[
        When the World is created using `lovr.physics.newWorld`, it is possible to specify a list of
        collision tags for the World.  Colliders can then be assigned a tag.  You can enable and
        disable collision between pairs of tags.  There are also some helper functions to quickly
        identify pairs of colliders that are near each other and test whether or not they are
        colliding.  These are used internally by default by `World:update`, but you can override
        this behavior and use the functions directly for custom collision behavior.
      ]]
    }
  },
  notes = [[
    Be sure to update the World in `lovr.update` using `World:update`, otherwise everything will
    stand still.
  ]]
}
