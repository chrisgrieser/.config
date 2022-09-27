return {
  summary = 'Get the depth buffer used by the Canvas.',
  description = [[
    Returns the depth buffer used by the Canvas as a Texture.  If the Canvas was not created with a
    readable depth buffer (the `depth.readable` flag in `lovr.graphics.newCanvas`), then this
    function will return `nil`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'texture',
      type = 'Texture',
      description = 'The depth Texture of the Canvas.'
    }
  },
  related = {
    'lovr.graphics.newCanvas'
  }
}
