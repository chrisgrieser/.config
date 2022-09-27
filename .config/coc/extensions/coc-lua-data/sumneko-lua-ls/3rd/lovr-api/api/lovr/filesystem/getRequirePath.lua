return {
  summary = 'Get the require path.',
  description = [[
    Returns the require path.  The require path is a semicolon-separated list of patterns that LÖVR
    will use to search for files when they are `require`d.  Any question marks in the pattern will
    be replaced with the module that is being required.  It is similar to Lua\'s `package.path`
    variable, but the main difference is that the patterns are relative to the virtual filesystem.
  ]],
  arguments = {},
  returns = {
    {
      name = 'path',
      type = 'string',
      description = 'The semicolon separated list of search patterns.'
    }
  },
  notes = ' The default reqiure path is \'?.lua;?/init.lua\'.'
}
