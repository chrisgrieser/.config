return {
  summary = 'Different types of Source effects.',
  description = 'Different types of effects that can be applied with `Source:setEffectEnabled`.',
  values = {
    {
      name = 'absorption',
      description = 'Models absorption as sound travels through the air, water, etc.'
    },
    {
      name = 'falloff',
      description = 'Decreases audio volume with distance (1 / max(distance, 1)).'
    },
    {
      name = 'occlusion',
      description = 'Causes audio to drop off when the Source is occluded by geometry.'
    },
    {
      name = 'reverb',
      description = 'Models reverb caused by audio bouncing off of geometry.'
    },
    {
      name = 'spatialization',
      description = 'Spatializes the Source using either simple panning or an HRTF.'
    },
    {
      name = 'transmission',
      description = 'Causes audio to be heard through walls when occluded, based on audio materials.'
    }
  },
  notes = [[
    The active spatializer will determine which effects are supported.  If an unsupported effect is
    enabled on a Source, no error will be reported.  Instead, it will be silently ignored.

    TODO: expose a table of supported effects for spatializers in docs or from Lua.
  ]]
}
