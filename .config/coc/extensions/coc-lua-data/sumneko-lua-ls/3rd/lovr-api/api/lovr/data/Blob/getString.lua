return {
  summary = 'Get the Blob\'s contents as a string.',
  description = 'Returns a binary string containing the Blob\'s data.',
  arguments = {},
  returns = {
    {
      name = 'data',
      type = 'string',
      description = 'The Blob\'s data.'
    }
  },
  example = {
    description = 'Manually copy a file using Blobs:',
    code = [[
      blob = lovr.filesystem.newBlob('image.png')
      lovr.filesystem.write('copy.png', blob:getString())
    ]]
  }
}
