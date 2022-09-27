return {
  summary = 'Render to the Canvas using a function.',
  description = [[
    Renders to the Canvas using a function.  All graphics functions inside the callback will affect
    the Canvas contents instead of directly rendering to the headset.  This can be used in
    `lovr.update`.
  ]],
  arguments = {
    {
      name = 'callback',
      type = 'function',
      arguments = {
        {
          name = '...',
          type = '*'
        }
      },
      returns = {},
      description = 'The function to use to render to the Canvas.'
    },
    {
      name = '...',
      type = '*',
      description = 'Additional arguments to pass to the callback.'
    }
  },
  returns = {},
  notes = [[
    Make sure you clear the contents of the canvas before rendering by using `lovr.graphics.clear`.
    Otherwise there might be data in the canvas left over from a previous frame.

    Also note that the transform stack is not modified by this function.  If you plan on modifying
    the transform stack inside your callback it may be a good idea to use `lovr.graphics.push` and
    `lovr.graphics.pop` so you can revert to the previous transform afterwards.
  ]]
}
