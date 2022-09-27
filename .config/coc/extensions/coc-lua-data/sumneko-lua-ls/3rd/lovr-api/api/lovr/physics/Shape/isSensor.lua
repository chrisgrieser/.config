return {
  summary = 'Check if the Shape is a sensor.',
  description = [[
    Returns whether the Shape is a sensor.  Sensors do not trigger any collision response, but they
    still report collisions in `World:collide`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'sensor',
      type = 'boolean',
      description = 'Whether the Shape is a sensor.'
    }
  }
}
