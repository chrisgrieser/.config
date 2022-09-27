return {
  tag = 'shapes',
  summary = 'Create a new CylinderShape.',
  description = 'Creates a new CylinderShape.',
  arguments = {
    {
      name = 'radius',
      type = 'number',
      default = '1',
      description = 'The radius of the cylinder, in meters.'
    },
    {
      name = 'length',
      type = 'number',
      default = '1',
      description = 'The length of the cylinder, in meters.'
    }
  },
  returns = {
    {
      name = 'cylinder',
      type = 'CylinderShape',
      description = 'The new CylinderShape.'
    }
  },
  notes = 'A Shape can be attached to a Collider using `Collider:addShape`.',
  related = {
    'CylinderShape',
    'lovr.physics.newBoxShape',
    'lovr.physics.newCapsuleShape',
    'lovr.physics.newSphereShape'
  }
}
