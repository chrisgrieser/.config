return {
  tag = 'headset',
  summary = 'Render to the headset using a function.',
  description = [[
    Renders to each eye of the headset using a function.

    This function takes care of setting the appropriate graphics transformations to ensure that the
    scene is rendered as though it is being viewed through each eye of the player.  It also takes
    care of setting the correct projection for the headset lenses.

    If the headset module is enabled, this function is called automatically by `lovr.run` with
    `lovr.draw` as the callback.
  ]],
  arguments = {
    {
      name = 'callback',
      type = 'function',
      arguments = {},
      returns = {},
      description = [[
        The function used to render.  Any functions called will render to the headset instead of to
        the window.
      ]]
    }
  },
  returns = {},
  notes = [[
    When using the `pico` headset driver, headset rendering is asynchronous and the callback passed
    to `lovr.headset.renderTo` will not be called immediately.

    At the beginning of the callback, the display is cleared to the background color.  The
    background color can be changed using `lovr.graphics.setBackgroundColor`.

    If the callback is `nil`, an empty frame cleared to current graphics background color will be
    submitted to the headset.
  ]]
}
