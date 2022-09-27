return {
  tag = 'colliders',
  summary = 'Add a Collider with a MeshShape to the World.',
  description = 'Adds a new Collider to the World with a MeshShape already attached.',
  arguments = {
    vertices = {
      type = 'table',
      description = 'The table of vertices in the mesh.  Each vertex is a table with 3 numbers.'
    },
    indices = {
      type = 'table',
      description = [[
        A table of triangle indices representing how the vertices are connected in the Mesh.
      ]]
    },
    model = {
      type = 'Model',
      description = [[
        A Model to use for the mesh data.  Similar to calling `Model:getTriangles` and passing it to
        this function, but has better performance.
      ]]
    }
  },
  returns = {
    collider = {
      type = 'Collider',
      description = 'The new Collider.'
    }
  },
  variants = {
    {
      arguments = { 'vertices', 'indices' },
      returns = { 'collider' }
    },
    {
      arguments = { 'model' },
      returns = { 'collider' }
    }
  },
  related = {
    'Collider',
    'World:newCollider',
    'World:newBoxCollider',
    'World:newCapsuleCollider',
    'World:newCylinderCollider',
    'World:newSphereCollider',
    'Model:getTriangles'
  }
}
