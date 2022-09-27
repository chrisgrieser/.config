return {
  summary = 'Get the bytes backing this Image as a `Blob`.',
  description = 'Returns a Blob containing the raw bytes of the Image.',
  arguments = {},
  returns = {
    {
      name = 'blob',
      type = 'Blob',
      description = 'The Blob instance containing the bytes for the `Image`.'
    }
  },
  related = {
    'Blob:getPointer',
    'Sound:getBlob'
  }
}
