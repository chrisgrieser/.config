return {
  tag = 'colliders',
  summary = 'Add a Collider with a BoxShape to the World.',
  description = 'Adds a new Collider to the World with a BoxShape already attached.',
  arguments = {
    {
      name = 'x',
      type = 'number',
      default = '0',
      description = 'The x coordinate of the center of the box.'
    },
    {
      name = 'y',
      type = 'number',
      default = '0',
      description = 'The y coordinate of the center of the box.'
    },
    {
      name = 'z',
      type = 'number',
      default = '0',
      description = 'The z coordinate of the center of the box.'
    },
    {
      name = 'width',
      type = 'number',
      default = '1',
      description = 'The total width of the box, in meters.'
    },
    {
      name = 'height',
      type = 'number',
      default = 'width',
      description = 'The total height of the box, in meters.'
    },
    {
      name = 'depth',
      type = 'number',
      default = 'width',
      description = 'The total depth of the box, in meters.'
    }
  },
  returns = {
    {
      name = 'collider',
      type = 'Collider',
      description = 'The new Collider.'
    }
  },
  related = {
    'BoxShape',
    'Collider',
    'World:newCollider',
    'World:newCapsuleCollider',
    'World:newCylinderCollider',
    'World:newMeshCollider',
    'World:newSphereCollider'
  }
}
