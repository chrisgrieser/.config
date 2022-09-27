return {
  summary = 'Check if the Canvas is stereo.',
  description = [[
    Returns whether the Canvas was created with the `stereo` flag.  Drawing something to a stereo
    Canvas will draw it to two viewports in the left and right half of the Canvas, using transform
    information from two different eyes.
  ]],
  arguments = {},
  returns = {
    {
      name = 'stereo',
      type = 'boolean',
      description = 'Whether the Canvas is stereo.'
    }
  },
  related = {
    'lovr.graphics.newCanvas',
    'lovr.graphics.fill'
  }
}
