return {
  tag = 'callbacks',
  summary = 'Called once at startup.',
  description = [[
    This callback is called once when the app starts.  It should be used to perform initial setup
    work, like loading resources and initializing classes and variables.
  ]],
  arguments = {
    {
      name = 'args',
      type = 'table',
      description = 'The command line arguments provided to the program.'
    }
  },
  returns = {},
  example = [[
    function lovr.load(args)
      model = lovr.graphics.newModel('cena.gltf')
      texture = lovr.graphics.newTexture('cena.png')
      levelGeometry = lovr.graphics.newMesh(1000)
      effects = lovr.graphics.newShader('vert.glsl', 'frag.glsl')
      loadLevel(1)
    end
  ]],
  notes = [[
    If the project was loaded from a restart using `lovr.event.restart`, the return value from the
    previously-run `lovr.restart` callback will be made available to this callback as the `restart`
    key in the `args` table.

    The `args` table follows the [Lua
    standard](https://en.wikibooks.org/wiki/Lua_Programming/command_line_parameter).  The arguments
    passed in from the shell are put into a global table named `arg` and passed to `lovr.load`, but
    with indices offset such that the "script" (the project path) is at index 0.  So all arguments
    (if any) intended for the project are at successive indices starting with 1, and the executable
    and its "internal" arguments are in normal order but stored in negative indices.
  ]],
  related = {
    'lovr.quit'
  }
}
