return {
  tag = 'worldBasics',
  summary = 'Cast a ray through the World.',
  description = [[
    Casts a ray through the World, calling a function every time the ray intersects with a Shape.
  ]],
  arguments = {
    {
      name = 'x1',
      type = 'number',
      description = 'The x coordinate of the starting position of the ray.',
    },
    {
      name = 'y1',
      type = 'number',
      description = 'The y coordinate of the starting position of the ray.',
    },
    {
      name = 'z1',
      type = 'number',
      description = 'The z coordinate of the starting position of the ray.',
    },
    {
      name = 'x2',
      type = 'number',
      description = 'The x coordinate of the ending position of the ray.',
    },
    {
      name = 'y2',
      type = 'number',
      description = 'The y coordinate of the ending position of the ray.',
    },
    {
      name = 'z2',
      type = 'number',
      description = 'The z coordinate of the ending position of the ray.',
    },
    {
      name = 'callback',
      type = 'function',
      arguments = {
        {
          name = 'shape',
          type = 'Shape'
        },
        {
          name = 'x',
          type = 'number'
        },
        {
          name = 'y',
          type = 'number'
        },
        {
          name = 'z',
          type = 'number'
        },
        {
          name = 'nx',
          type = 'number'
        },
        {
          name = 'ny',
          type = 'number'
        },
        {
          name = 'nz',
          type = 'number'
        }
      },
      returns = {},
      description = 'The function to call when an intersection is detected.'
    }
  },
  returns = {},
  notes = [[
    The callback is passed the shape that was hit, the hit position (in world coordinates), and the
    normal vector of the hit.
  ]],
  example = [[
    function lovr.load()
      world = lovr.physics.newWorld()
      world:newSphereCollider(0, 0, 0, 2)

      -- Cast a ray through the sphere
      local x1, y1, z1 = .5, 3, 0
      local x2, y2, z2 = -.5, -2, 0
      world:raycast(x1, y1, z1, x2, y2, z2, function(shape, x, y, z, nx, ny, nz)
        print('Collision detected!', shape, x, y, z, nx, ny, nz)
      end)
    end
  ]]
}
