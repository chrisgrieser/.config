return {
  tag = 'graphicsState',
  summary = 'Set or disable the depth test.',
  description = [[
    Sets the current depth test.  The depth test controls how overlapping objects are rendered.
  ]],
  arguments = {
    {
      name = 'compareMode',
      type = 'CompareMode',
      default = 'nil',
      description = 'The new depth test.  Use `nil` to disable the depth test.'
    },
    {
      name = 'write',
      type = 'boolean',
      default = 'true',
      description = 'Whether pixels will have their z value updated when rendered to.'
    }
  },
  returns = {},
  notes = [[
    The depth test is an advanced technique to control how 3D objects overlap each other when they
    are rendered.  It works as follows:

    - Each pixel keeps track of its z value as well as its color.
    - If `write` is enabled when something is drawn, then any pixels that are drawn will have their
      z values updated.
    - Additionally, anything drawn will first compare the existing z value of a pixel with the new z
      value.  The `compareMode` setting determines how this comparison is performed.  If the
      comparison succeeds, the new pixel will overwrite the previous one, otherwise that pixel won't
      be rendered to.

    Smaller z values are closer to the camera.

    The default compare mode is `lequal`, which usually gives good results for normal 3D rendering.
  ]]
}
