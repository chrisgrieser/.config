return {
  tag = 'worldCollision',
  summary = 'Iterate over pairs of nearby shapes.',
  description = [[
    Returns an iterator that can be used to iterate over "overlaps", or potential collisions between
    pairs of shapes in the World.  This should be called after using `World:detectOverlaps` to
    compute the list of overlaps. Usually this is called automatically by `World:update`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'iterator',
      type = 'function',
      arguments = {},
      returns = {},
      description = 'A Lua iterator, usable in a for loop.'
    }
  },
  example = [[
    world:computeOverlaps()
    for shapeA, shapeB in world:overlaps() do
      local areColliding = world:collide(shapeA, shapeB)
      print(shapeA, shapeB, areColliding)
    end
  ]],
  related = {
    'World:computeOverlaps',
    'World:collide',
    'World:update'
  }
}
