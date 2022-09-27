return {
  tag = 'graphicsState',
  summary = 'Get the active shader.',
  description = 'Returns the active shader.',
  arguments = {},
  returns = {
    {
      name = 'shader',
      type = 'Shader',
      description = 'The active shader object, or `nil` if none is active.'
    }
  }
}
