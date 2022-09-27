return {
  summary = 'An object that loads and stores data for 3D models.',
  description = [[
    A ModelData is a container object that loads and holds data contained in 3D model files.  This
    can include a variety of things like the node structure of the asset, the vertex data it
    contains, contains, the `Image` and `Material` properties, and any included animations.

    The current supported formats are OBJ, glTF, and STL.

    Usually you can just load a `Model` directly, but using a `ModelData` can be helpful if you want
    to load models in a thread or access more low-level information about the Model.
  ]],
  constructor = 'lovr.data.newModelData'
}
