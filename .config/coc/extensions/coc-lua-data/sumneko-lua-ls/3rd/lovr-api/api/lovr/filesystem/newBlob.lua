return {
  summary = 'Create a new Blob from a file.',
  description = 'Creates a new Blob that contains the contents of a file.',
  arguments = {
    {
      name = 'filename',
      type = 'string',
      description = 'The file to load.'
    }
  },
  returns = {
    {
      name = 'blob',
      type = 'Blob',
      description = 'The new Blob.'
    }
  },
  related = {
    'lovr.data.newBlob',
    'Blob'
  }
}
