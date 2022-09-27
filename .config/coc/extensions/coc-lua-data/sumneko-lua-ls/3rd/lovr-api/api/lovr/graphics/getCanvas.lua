return {
  tag = 'graphicsState',
  summary = 'Get the active Canvas.',
  description = [[
    Returns the active Canvas.  Usually when you render something it will render directly to the
    headset.  If a Canvas object is active, things will be rendered to the textures attached to the
    Canvas instead.
  ]],
  arguments = {},
  returns = {
    {
      name = 'canvas',
      type = 'Canvas',
      description = 'The active Canvas, or `nil` if no canvas is set.'
    }
  },
  related = {
    'Canvas:renderTo',
    'Canvas'
  }
}
