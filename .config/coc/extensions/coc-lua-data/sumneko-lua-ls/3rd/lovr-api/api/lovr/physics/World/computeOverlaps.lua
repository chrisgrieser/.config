return {
  tag = 'worldCollision',
  summary = 'Compute pairs of shapes that are close to each other.',
  description = [[
    Detects which pairs of shapes in the world are near each other and could be colliding.  After
    calling this function, the `World:overlaps` iterator can be used to iterate over the overlaps,
    and `World:collide` can be used to resolve a collision for the shapes (if any). Usually this is
    called automatically by `World:update`.
  ]],
  arguments = {},
  returns = {},
  example = [[
    world:computeOverlaps()
    for shapeA, shapeB in world:overlaps() do
      local areColliding = world:collide(shapeA, shapeB)
      print(shapeA, shapeB, areColliding)
    end
  ]],
  related = {
    'World:overlaps',
    'World:collide',
    'World:update'
  }
}
