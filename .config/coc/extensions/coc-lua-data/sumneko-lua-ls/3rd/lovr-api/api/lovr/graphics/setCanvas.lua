return {
  tag = 'graphicsState',
  summary = 'Set the active Canvas.',
  description = [[
    Sets or disables the active Canvas object.  If there is an active Canvas, things will be
    rendered to the Textures attached to that Canvas instead of to the headset.
  ]],
  arguments = {
    {
      name = 'canvas',
      type = 'Canvas',
      default = 'nil',
      description = 'The new active Canvas object, or `nil` to just render to the headset.'
    }
  },
  returns = {},
  related = {
    'Canvas:renderTo',
    'Canvas'
  }
}
