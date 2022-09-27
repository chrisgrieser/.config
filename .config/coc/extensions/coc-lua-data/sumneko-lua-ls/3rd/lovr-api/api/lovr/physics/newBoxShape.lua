return {
  tag = 'shapes',
  summary = 'Create a new BoxShape.',
  description = 'Creates a new BoxShape.',
  arguments = {
    {
      name = 'width',
      type = 'number',
      default = '1',
      description = 'The width of the box, in meters.'
    },
    {
      name = 'height',
      type = 'number',
      default = 'width',
      description = 'The height of the box, in meters.'
    },
    {
      name = 'depth',
      type = 'number',
      default = 'width',
      description = 'The depth of the box, in meters.'
    }
  },
  returns = {
    {
      name = 'box',
      type = 'BoxShape',
      description = 'The new BoxShape.'
    }
  },
  notes = 'A Shape can be attached to a Collider using `Collider:addShape`.',
  related = {
    'BoxShape',
    'lovr.physics.newCapsuleShape',
    'lovr.physics.newCylinderShape',
    'lovr.physics.newSphereShape'
  }
}
