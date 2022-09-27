return {
  summary = 'Different types of coordinate space origins.',
  description = [[
    Represents the different types of origins for coordinate spaces.  An origin of "floor" means
    that the origin is on the floor in the middle of a room-scale play area.  An origin of "head"
    means that no positional tracking is available, and consequently the origin is always at the
    position of the headset.
  ]],
  values = {
    {
      name = 'head',
      description = 'The origin is at the head.'
    },
    {
      name = 'floor',
      description = 'The origin is on the floor.'
    }
  }
}
