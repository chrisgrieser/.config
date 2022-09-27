return {
  summary = 'Get the Collider the Shape is attached to.',
  description = 'Returns the Collider the Shape is attached to.',
  arguments = {},
  returns = {
    {
      name = 'collider',
      type = 'Collider',
      description = 'The Collider the Shape is attached to.'
    }
  },
  notes = 'A Shape can only be attached to one Collider at a time.',
  related = {
    'Collider',
    'Collider:addShape',
    'Collider:removeShape'
  }
}
