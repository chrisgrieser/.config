return {
  summary = 'Get the vertex format of the Mesh.',
  description = [[
    Get the format table of the Mesh's vertices.  The format table describes the set of data that
    each vertex contains.
  ]],
  arguments = {},
  returns = {
    {
      name = 'format',
      type = 'table',
      description = [[
        The table of vertex attributes.  Each attribute is a table containing the name of the
        attribute, the `AttributeType`, and the number of components.
      ]]
    }
  }
}
