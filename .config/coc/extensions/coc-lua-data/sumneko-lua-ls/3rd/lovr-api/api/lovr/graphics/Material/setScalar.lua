return {
  summary = 'Set a scalar property of the Material.',
  description = 'Sets a numeric property of a Material.  Scalar properties default to 1.0.',
  arguments = {
    {
      name = 'scalarType',
      type = 'MaterialScalar',
      description = 'The type of property to set.'
    },
    {
      name = 'x',
      type = 'number',
      description = 'The value of the property.'
    }
  },
  returns = {},
  related = {
    'MaterialScalar'
  }
}
