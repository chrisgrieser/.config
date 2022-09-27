return {
  summary = 'Mount a directory or archive.',
  description = [[
    Mounts a directory or `.zip` archive, adding it to the virtual filesystem.  This
    allows you to read files from it.
  ]],
  arguments = {
    {
      name = 'path',
      type = 'string',
      description = 'The path to mount.'
    },
    {
      name = 'mountpoint',
      type = 'string',
      default = [['/']],
      description = 'The path in the virtual filesystem to mount to.'
    },
    {
      name = 'append',
      type = 'boolean',
      default = 'false',
      description = [[
        Whether the archive will be added to the end or the beginning of the search path.
      ]]
    },
    {
      name = 'root',
      type = 'string',
      default = 'nil',
      description = [[
        A subdirectory inside the archive to use as the root.  If `nil`, the actual root of the
        archive is used.
      ]]
    }
  },
  returns = {
    {
      name = 'success',
      type = 'boolean',
      description = 'Whether the archive was successfully mounted.'
    }
  },
  notes = [[
    The `append` option lets you control the priority of the archive's files in the event of naming
    collisions.

    This function is not thread safe.  Mounting or unmounting an archive while other threads call
    lovr.filesystem functions is not supported.
  ]],
  example = {
    description = 'Mount `data.zip` with a file `images/background.png`:',
    code = [[
      lovr.filesystem.mount('data.zip', 'assets')
      print(lovr.filesystem.isFile('assets/images/background.png')) -- true
    ]]
  },
  related = {
    'lovr.filesystem.unmount'
  }
}
