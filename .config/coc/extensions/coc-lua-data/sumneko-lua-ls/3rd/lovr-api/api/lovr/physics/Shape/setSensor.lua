return {
  summary = 'Set the sensor status for the Shape.',
  description = [[
    Sets whether this Shape is a sensor.  Sensors do not trigger any collision response, but they
    still report collisions in `World:collide`.
  ]],
  arguments = {
    {
      name = 'sensor',
      type = 'boolean',
      description = 'Whether the Shape should be a sensor.'
    }
  },
  returns = {}
}
