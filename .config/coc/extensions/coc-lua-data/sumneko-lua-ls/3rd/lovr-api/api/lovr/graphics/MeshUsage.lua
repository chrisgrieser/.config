return {
  summary = 'How a Mesh is going to be updated.',
  description = [[
    Meshes can have a usage hint, describing how they are planning on being updated.  Setting the
    usage hint allows the graphics driver optimize how it handles the data in the Mesh.
  ]],
  values = {
    {
      name = 'static',
      description = 'The Mesh contents will rarely change.'
    },
    {
      name = 'dynamic',
      description = 'The Mesh contents will change often.'
    },
    {
      name = 'stream',
      description = [[
        The Mesh contents will change constantly, potentially multiple times each frame.
      ]]
    }
  }
}
