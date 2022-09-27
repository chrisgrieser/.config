return {
  summary = 'Encode the Image as png.',
  description = 'Encodes the Image to an uncompressed png.  This intended mainly for debugging.',
  arguments = {},
  returns = {
    {
      name = 'blob',
      type = 'Blob',
      description = 'A new Blob containing the PNG image data.'
    }
  },
  related = {
    'lovr.filesystem.write'
  }
}
