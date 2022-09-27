return {
  tag = 'graphicsState',
  summary = 'Set the active font.',
  description = 'Sets the active font used to render text with `lovr.graphics.print`.',
  arguments = {
    {
      name = 'font',
      type = 'Font',
      default = 'nil',
      description = 'The font to use.  If `nil`, the default font is used (Varela Round).'
    }
  },
  returns = {},
  related = {
    'lovr.graphics.print'
  }
}
