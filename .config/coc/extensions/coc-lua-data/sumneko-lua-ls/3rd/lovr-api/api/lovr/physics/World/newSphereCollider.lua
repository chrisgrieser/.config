return {
  tag = 'colliders',
  summary = 'Add a Collider with a SphereShape to the World.',
  description = 'Adds a new Collider to the World with a SphereShape already attached.',
  arguments = {
    {
      name = 'x',
      type = 'number',
      default = '0',
      description = 'The x coordinate of the center of the sphere.'
    },
    {
      name = 'y',
      type = 'number',
      default = '0',
      description = 'The y coordinate of the center of the sphere.'
    },
    {
      name = 'z',
      type = 'number',
      default = '0',
      description = 'The z coordinate of the center of the sphere.'
    },
    {
      name = 'radius',
      type = 'number',
      default = '1',
      description = 'The radius of the sphere, in meters.'
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
    'SphereShape',
    'Collider',
    'World:newCollider',
    'World:newBoxCollider',
    'World:newCapsuleCollider',
    'World:newCylinderCollider',
    'World:newMeshCollider'
  }
}
