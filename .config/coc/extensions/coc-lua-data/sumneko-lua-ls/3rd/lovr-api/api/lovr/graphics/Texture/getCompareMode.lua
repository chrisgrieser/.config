return {
  summary = 'Get the CompareMode for the Texture.',
  description = 'Returns the compare mode for the texture.',
  arguments = {},
  returns = {
    {
      name = 'compareMode',
      type = 'CompareMode',
      description = 'The current compare mode, or `nil` if none is set.'
    }
  },
  related = {
    'lovr.graphics.getDepthTest'
  }
}
