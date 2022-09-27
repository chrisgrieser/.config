return {
  tag = 'graphicsObjects',
  summary = 'Create a new Model.',
  description = [[
    Creates a new Model from a file.  The supported 3D file formats are OBJ, glTF, and STL.
  ]],
  arguments = {
    filename = {
      type = 'string',
      description = 'The filename of the model to load.'
    },
    modelData = {
      type = 'ModelData',
      description = 'The ModelData containing the data for the Model.'
    }
  },
  returns = {
    model = {
      type = 'Model',
      description = 'The new Model.'
    }
  },
  variants = {
    {
      arguments = { 'filename' },
      returns = { 'model' }
    },
    {
      arguments = { 'modelData' },
      returns = { 'model' }
    }
  },
  notes = [[
    Diffuse and emissive textures will be loaded in the sRGB encoding, all other textures will be
    loaded as linear.

    Currently, the following features are not supported by the model importer:

    - OBJ: Quads are not supported (only triangles).
    - glTF: Sparse accessors are not supported.
    - glTF: Morph targets are not supported.
    - glTF: base64 images are not supported (base64 buffer data works though).
    - glTF: Only the default scene is loaded.
    - glTF: Currently, each skin in a Model can have up to 48 joints.
    - STL: ASCII STL files are not supported.
  ]]
}
