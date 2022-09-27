return {
  tag = 'headset',
  summary = 'Get the Texture containing a view of what\'s in the headset.',
  description = [[
    Returns a Texture that contains whatever is currently rendered to the headset.

    Sometimes this can be `nil` if the current headset driver doesn't have a mirror texture, which
    can happen if the driver renders directly to the display.  Currently the `desktop`, `webxr`, and
    `vrapi` drivers do not have a mirror texture.

    It also isn't guaranteed that the same Texture will be returned by subsequent calls to this
    function.  Currently, the `oculus` driver exhibits this behavior.
  ]],
  arguments = {},
  returns = {
    {
      name = 'mirror',
      type = 'Texture',
      description = 'The mirror texture.'
    }
  },
  related = {
    'lovr.mirror'
  }
}
