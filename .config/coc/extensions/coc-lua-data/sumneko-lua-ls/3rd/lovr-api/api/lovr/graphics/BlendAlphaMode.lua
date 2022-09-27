return {
  summary = 'Different ways of blending alpha.',
  description = 'Different ways the alpha channel of pixels affects blending.',
  values = {
    {
      name = 'alphamultiply',
      description = 'Color channel values are multiplied by the alpha channel during blending.'
    },
    {
      name = 'premultiplied',
      description = [[
        Color channels are not multiplied by the alpha channel.  This should be used if the pixels
        being drawn have already been blended, or "pre-multiplied", by the alpha channel.
      ]]
    }
  },
  notes = [[
    The premultiplied mode should be used if pixels being drawn have already been blended, or
    "pre-multiplied", by the alpha channel.  This happens when rendering a framebuffer that contains
    pixels with transparent alpha values, since the stored color values have already been faded by
    alpha and don't need to be faded a second time with the alphamultiply blend mode.
  ]],
  related = {
    'BlendMode',
    'lovr.graphics.getBlendMode',
    'lovr.graphics.setBlendMode'
  }
}
