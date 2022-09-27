return {
  summary = 'Create a new ModelData.',
  description = 'Loads a 3D model from a file.  The supported 3D file formats are OBJ and glTF.',
  arguments = {
    filename = {
      type = 'string',
      description = 'The filename of the model to load.'
    },
    blob = {
      type = 'Blob',
      description = 'The Blob containing data for a model to decode.'
    }
  },
  returns = {
    modelData = {
      type = 'ModelData',
      description = 'The new ModelData.'
    }
  },
  variants = {
    {
      arguments = { 'filename' },
      returns = { 'modelData' }
    },
    {
      arguments = { 'blob' },
      returns = { 'modelData' }
    }
  }
}
