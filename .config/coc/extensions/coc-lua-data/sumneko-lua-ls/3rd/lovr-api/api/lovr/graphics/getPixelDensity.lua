return {
  tag = 'window',
  summary = 'Get the pixel density of the window.',
  description = [[
    Returns the pixel density of the window.  On "high-dpi" displays, this will be `2.0`, indicating
    that there are 2 pixels for every window coordinate.  On a normal display it will be `1.0`,
    meaning that the pixel to window-coordinate ratio is 1:1.
  ]],
  arguments = {},
  returns = {
    {
      name = 'density',
      type = 'number',
      description = 'The pixel density of the window.'
    }
  },
  notes = [[
    If the window isn't created yet, this function will return 0.
  ]],
  related = {
    'lovr.graphics.getWidth',
    'lovr.graphics.getHeight',
    'lovr.graphics.getDimensions',
    'lovr.graphics.createWindow',
    'lovr.conf'
  }
}
