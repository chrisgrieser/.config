return {
  tag = 'sourceEffects',
  summary = 'Get the orientation of the Source.',
  description = 'Returns the orientation of the Source, in angle/axis representation.',
  arguments = {},
  returns = {
    {
      name = 'angle',
      type = 'number',
      description = 'The number of radians the Source is rotated around its axis of rotation.'
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
    'Source:getPosition',
    'Source:getPose',
    'Source:getCone',
    'lovr.audio.getOrientation'
  }
}
