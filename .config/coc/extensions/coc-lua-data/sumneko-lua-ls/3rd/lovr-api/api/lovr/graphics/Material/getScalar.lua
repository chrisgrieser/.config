return {
  summary = 'Get a scalar property of the Material.',
  description = 'Returns a numeric property of a Material.  Scalar properties default to 1.0.',
  arguments = {
    {
      name = 'scalarType',
      type = 'MaterialScalar',
      description = 'The type of property to get.'
    }
  },
  returns = {
    {
      name = 'x',
      type = 'number',
      description = 'The value of the property.'
    }
  },
  related = {
    'MaterialScalar'
  }
}
