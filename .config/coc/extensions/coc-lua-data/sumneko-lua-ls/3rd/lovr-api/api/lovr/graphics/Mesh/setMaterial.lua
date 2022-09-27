return {
  summary = 'Apply a Material to the Mesh.',
  description = [[
    Applies a Material to the Mesh.  This will cause it to use the Material's properties whenever it
    is rendered.
  ]],
  arguments = {
    {
      name = 'material',
      type = 'Material',
      description = 'The Material to apply.'
    }
  },
  returns = {}
}
