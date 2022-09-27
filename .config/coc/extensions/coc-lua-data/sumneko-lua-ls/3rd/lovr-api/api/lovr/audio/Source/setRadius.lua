return {
  tag = 'sourceEffects',
  summary = 'Set the radius of the Source.',
  description = [[
    Sets the radius of the Source, in meters.

    This does not control falloff or attenuation.  It is only used for smoothing out occlusion.  If
    a Source doesn't have a radius, then when it becomes occluded by a wall its volume will
    instantly drop.  Giving the Source a radius that approximates its emitter's size will result in
    a smooth transition between audible and occluded, improving realism.
  ]],
  arguments = {
    {
      name = 'radius',
      type = 'number',
      description = 'The new radius of the Source, in meters.'
    }
  },
  returns = {}
}
