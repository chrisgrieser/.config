return {
  tag = 'listener',
  summary = 'Set the orientation of the listener.',
  description = 'Sets the orientation of the virtual audio listener in angle/axis representation.',
  arguments = {
    {
      name = 'angle',
      type = 'number',
      description = 'The number of radians the listener should be rotated around its rotation axis.'
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
  returns = {}
}
