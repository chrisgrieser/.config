return {
  summary = 'Remove a file or directory.',
  description = 'Remove a file or directory in the save directory.',
  arguments = {
    {
      name = 'path',
      type = 'string',
      description = 'The file or directory to remove.'
    }
  },
  returns = {
    {
      name = 'success',
      type = 'boolean',
      description = 'Whether the path was removed.'
    }
  },
  notes = [[
    A directory can only be removed if it is empty.

    To recursively remove a folder, use this function with `lovr.filesystem.getDirectoryItems`.
  ]]
}
