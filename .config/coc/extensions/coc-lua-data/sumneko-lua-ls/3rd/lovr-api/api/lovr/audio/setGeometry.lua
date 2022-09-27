return {
  tag = 'listener',
  summary = 'Set the geometry for audio effects.',
  description = [[
    Sets a mesh of triangles to use for modeling audio effects, using a table of vertices or a
    Model.  When the appropriate effects are enabled, audio from `Source` objects will correctly be
    occluded by walls and bounce around to create realistic reverb.

    An optional `AudioMaterial` may be provided to specify the acoustic properties of the geometry.
  ]],
  arguments = {
    vertices = {
      type = 'table',
      description = [[
        A flat table of vertices.  Each vertex is 3 numbers representing its x, y, and z position.
        The units used for audio coordinates are up to you, but meters are recommended.
      ]]
    },
    indices = {
      type = 'table',
      description = [[
        A list of indices, indicating how the vertices are connected into triangles.  Indices are
        1-indexed and are 32 bits (they can be bigger than 65535).
      ]]
    },
    model = {
      type = 'Model',
      description = 'A model to use for the audio geometry.'
    },
    material = {
      type = 'AudioMaterial',
      default = [['generic']],
      description = 'The acoustic material to use.'
    }
  },
  returns = {
    success = {
      type = 'boolean',
      description = [[
        Whether audio geometry is supported by the current spatializer and the geometry was loaded
        successfully.
      ]]
    }
  },
  variants = {
    {
      arguments = { 'vertices', 'indices', 'material' },
      returns = { 'success' }
    },
    {
      arguments = { 'model', 'material' },
      returns = { 'success' }
    }
  },
  notes = [[
    This is currently only supported/used by the `phonon` spatializer.

    The `Effect`s that use geometry are:

    - `occlusion`
    - `reverb`
    - `transmission`

    If an existing geometry has been set, this function will replace it.

    The triangles must use counterclockwise winding.
  ]],
  related = {
    'lovr.audio.getSpatializer',
    'Source:setEffectEnabled'
  }
}
