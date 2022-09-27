return {
  tag = 'colliders',
  summary = 'Add a Collider with a CylinderShape to the World.',
  description = 'Adds a new Collider to the World with a CylinderShape already attached.',
  arguments = {
    {
      name = 'x',
      type = 'number',
      default = '0',
      description = 'The x coordinate of the center of the cylinder.'
    },
    {
      name = 'y',
      type = 'number',
      default = '0',
      description = 'The y coordinate of the center of the cylinder.'
    },
    {
      name = 'z',
      type = 'number',
      default = '0',
      description = 'The z coordinate of the center of the cylinder.'
    },
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
      name = 'collider',
      type = 'Collider',
      description = 'The new Collider.'
    }
  },
  related = {
    'CylinderShape',
    'Collider',
    'World:newCollider',
    'World:newBoxCollider',
    'World:newCapsuleCollider',
    'World:newMeshCollider',
    'World:newSphereCollider'
  }
}
