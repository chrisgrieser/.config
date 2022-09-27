return {
  summary = 'Get the application data directory.',
  description = [[
    Returns the application data directory.  This will be something like:

    - `C:\Users\user\AppData\Roaming` on Windows.
    - `/home/user/.config` on Linux.
    - `/Users/user/Library/Application Support` on macOS.
  ]],
  arguments = {},
  returns = {
    {
      name = 'path',
      type = 'string',
      description = 'The absolute path to the appdata directory.'
    }
  }
}
