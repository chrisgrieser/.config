return {
  tag = 'colliders',
  summary = 'Add a Collider to the World.',
  description = 'Adds a new Collider to the World.',
  arguments = {
    {
      name = 'x',
      type = 'number',
      default = '0',
      description = 'The x position of the Collider.'
    },
    {
      name = 'y',
      type = 'number',
      default = '0',
      description = 'The y position of the Collider.'
    },
    {
      name = 'z',
      type = 'number',
      default = '0',
      description = 'The z position of the Collider.'
    }
  },
  returns = {
    {
      name = 'collider',
      type = 'Collider',
      description = 'The new Collider.'
    }
  },
  notes = [[
    This function creates a collider without any shapes attached to it, which means it won't collide
    with anything.  To add a shape to the collider, use `Collider:addShape`, or use one of the
    following functions to create the collider:

    - `World:newBoxCollider`
    - `World:newCapsuleCollider`
    - `World:newCylinderCollider`
    - `World:newSphereCollider`
  ]],
  example = {
    description = [[
      Create a new world, add a collider to it, and update it, printing out the collider's position
      as it falls.
    ]],
    code = [[
      function lovr.load()
        world = lovr.physics.newWorld()
        box = world:newBoxCollider()
      end

      function lovr.update(dt)
        world:update(dt)
        print(box:getPosition())
      end
    ]]
  },
  related = {
    'World:newBoxCollider',
    'World:newCapsuleCollider',
    'World:newCylinderCollider',
    'World:newMeshCollider',
    'World:newSphereCollider',
    'Collider',
    'Shape'
  }
}
