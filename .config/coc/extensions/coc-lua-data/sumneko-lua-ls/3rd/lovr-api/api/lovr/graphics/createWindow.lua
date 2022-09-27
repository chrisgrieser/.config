return {
  tag = 'window',
  summary = 'Creates the window.',
  description = 'Create the desktop window, usually used to mirror the headset display.',
  arguments = {
    {
      name = 'flags',
      type = 'table',
      description = 'Flags to customize the window\'s appearance and behavior.',
      table = {
        {
          name = 'width',
          type = 'number',
          default = '1080',
          description = 'The width of the window, or 0 to use the size of the monitor.'
        },
        {
          name = 'height',
          type = 'number',
          default = '600',
          description = 'The height of the window, or 0 to use the size of the monitor.'
        },
        {
          name = 'fullscreen',
          type = 'boolean',
          default = 'false',
          description = 'Whether the window should be fullscreen.'
        },
        {
          name = 'resizable',
          type = 'boolean',
          default = 'false',
          description = 'Whether the window should be resizable.'
        },
        {
          name = 'msaa',
          type = 'number',
          default = '0',
          description = 'The number of samples to use for multisample antialiasing.'
        },
        {
          name = 'title',
          type = 'string',
          default = 'LÖVR',
          description = 'The window title.'
        },
        {
          name = 'icon',
          type = 'string',
          default = 'nil',
          description = 'A path to an image to use for the window icon.'
        },
        {
          name = 'vsync',
          type = 'number',
          default = '0',
          description = [[
            0 to disable vsync, 1 to enable.  This is only a hint, and may not be respected if
            necessary for the current VR display.
          ]]
        }
      }
    }
  },
  returns = {},
  notes = [[
    This function can only be called once.  It is normally called internally, but you can override
    this by setting window to `nil` in conf.lua.  See `lovr.conf` for more information.

    The window must be created before any `lovr.graphics` functions can be used.
  ]],
  related = {
    'lovr.graphics.hasWindow',
    'lovr.conf'
  }
}
