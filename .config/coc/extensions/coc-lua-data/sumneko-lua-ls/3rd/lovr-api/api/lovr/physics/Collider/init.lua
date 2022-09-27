return {
  summary = 'A single entity in a physics simulation.',
  description = [[
    Colliders are objects that represent a single rigid body in a physics simulation.  They can
    have forces applied to them and collide with other colliders.
  ]],
  constructors = {
    'World:newCollider',
    'World:newBoxCollider',
    'World:newCapsuleCollider',
    'World:newCylinderCollider',
    'World:newSphereCollider'
  }
}
