return {
  tag = 'listener',
  summary = 'Get the orientation of the listener.',
  description = [[
    Returns the orientation of the virtual audio listener in angle/axis representation.
  ]],
  arguments = {},
  returns = {
    {
      name = 'angle',
      type = 'number',
      description = 'The number of radians the listener is rotated around its axis of rotation.'
    },
    {
      name = 'ax',
      type = 'number',
      description = 'The x component of the axis of rotation.'
    },
    {
      name = 'ay',
      type = 'number',
      description = 'The y component of the axis of rotation.'
    },
    {
      name = 'az',
      type = 'number',
      description = 'The z component of the axis of rotation.'
    }
  },
  related = {
    'lovr.audio.getPosition',
    'lovr.audio.getPose',
    'Source:getOrientation'
  }
}
