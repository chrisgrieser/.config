return {
  tag = 'shapes',
  summary = 'Create a new SphereShape.',
  description = 'Creates a new SphereShape.',
  arguments = {
    {
      name = 'radius',
      type = 'number',
      default = '1',
      description = 'The radius of the sphere, in meters.'
    }
  },
  returns = {
    {
      name = 'sphere',
      type = 'SphereShape',
      description = 'The new SphereShape.'
    }
  },
  notes = 'A Shape can be attached to a Collider using `Collider:addShape`.',
  related = {
    'SphereShape',
    'lovr.physics.newBoxShape',
    'lovr.physics.newCapsuleShape',
    'lovr.physics.newCylinderShape'
  }
}
