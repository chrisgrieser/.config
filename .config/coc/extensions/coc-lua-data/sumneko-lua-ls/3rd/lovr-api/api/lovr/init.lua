return {
  summary = 'In the beginning, there was nothing.',
  description = [[
    `lovr` is the single global table that is exposed to every LÖVR app. It contains a set of
    **modules** and a set of **callbacks**.
  ]],
  sections = {
    {
      name = 'Modules',
      tag = 'modules',
      description = [[
        Modules are the **what** of your app; you can use the functions in modules to tell LÖVR to
        do things. For example, you can draw things on the screen, figure out what buttons on a
        controller are pressed, or load a 3D model from a file.  Each module does what it says on
        the tin, so the `lovr.graphics` module deals with rendering graphics and `lovr.headset`
        allows you to interact with VR hardware.
      ]]
    },
    {
      name = 'Callbacks',
      tag = 'callbacks',
      description = [[
        Callbacks are the **when** of the application; you write code inside callbacks which LÖVR
        then calls at certain points in time.  For example, the `lovr.load` callback is called once
        at startup, and `lovr.focus` is called when the VR application gains or loses input focus.
      ]]
    },
    {
      name = 'Version',
      tag = 'version',
      description = 'This function can be used to get the current version of LÖVR.'
    }
  }
}
