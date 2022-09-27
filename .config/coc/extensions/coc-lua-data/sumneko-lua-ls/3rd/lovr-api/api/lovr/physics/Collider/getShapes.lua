return {
  summary = 'Get a list of Shapes attached to the Collider.',
  description = 'Returns a list of Shapes attached to the Collider.',
  arguments = {},
  returns = {
    {
      name = 'shapes',
      type = 'table',
      description = 'A list of Shapes attached to the Collider.'
    }
  },
  related = {
    'Collider:addShape',
    'Collider:removeShape',
    'Shape'
  }
}
