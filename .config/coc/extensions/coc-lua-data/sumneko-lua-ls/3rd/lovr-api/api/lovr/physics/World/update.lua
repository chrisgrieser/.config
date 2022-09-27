return {
  tag = 'worldBasics',
  summary = 'Update the World.',
  description = [[
    Updates the World, advancing the physics simulation forward in time and resolving collisions
    between colliders in the World.
  ]],
  arguments = {
    {
      name = 'dt',
      type = 'number',
      description = 'The amount of time to advance the simulation forward.'
    },
    {
      name = 'resolver',
      type = 'function',
      arguments = {
        {
          name = 'world',
          type = 'World'
        }
      },
      returns = {},
      default = 'nil',
      description = [[
        The collision resolver function to use.  This will be called before updating to allow for
        custom collision processing.  If absent, a default will be used.
      ]]
    }
  },
  returns = {},
  notes = [[
    It is common to pass the `dt` variable from `lovr.update` into this function.

    The default collision resolver function is:

        function defaultResolver(world)
          world:computeOverlaps()
          for shapeA, shapeB in world:overlaps() do
            world:collide(shapeA, shapeB)
          end
        end

    Additional logic could be introduced to the collision resolver function to add custom collision
    behavior or to change the collision parameters (like friction and restitution) on a
    per-collision basis.

    > If possible, use a fixed timestep value for updating the World. It will greatly improve the
    > accuracy of the simulation and reduce bugs. For more information on implementing a fixed
    > timestep loop, see [this article](http://gafferongames.com/game-physics/fix-your-timestep/).
  ]],
  related = {
    'World:computeOverlaps',
    'World:overlaps',
    'World:collide'
  }
}
