return {
  summary = 'Get a raw pointer to the Blob\'s data.',
  description = [[
    Returns a raw pointer to the Blob's data.  This can be used to interface with other C libraries
    using the LuaJIT FFI.  Use this only if you know what you're doing!
  ]],
  arguments = {},
  returns = {
    {
      name = 'pointer',
      type = 'userdata',
      description = 'A pointer to the data.'
    }
  }
}
