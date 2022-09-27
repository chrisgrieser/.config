return {
  summary = 'Add a Shape to the Collider.',
  description = [[
    Attaches a Shape to the collider.  Attached shapes will collide with other shapes in the world.
  ]],
  arguments = {
    {
      name = 'shape',
      type = 'Shape',
      description = 'The Shape to attach.'
    }
  },
  returns = {},
  related = {
    'Collider:removeShape',
    'Collider:getShapes',
    'Shape'
  }
}
