return {
  summary = 'Get the name of the save directory.',
  description = [[
    Returns the identity of the game, which is used as the name of the save directory.  The default
    is `default`.  It can be changed using `t.identity` in `lovr.conf`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'identity',
      type = 'string',
      description = 'The name of the save directory, or `nil` if it isn\'t set.'
    }
  },
  notes = [[
    On Android, this is always the package id (like `org.lovr.app`).
  ]]
}
