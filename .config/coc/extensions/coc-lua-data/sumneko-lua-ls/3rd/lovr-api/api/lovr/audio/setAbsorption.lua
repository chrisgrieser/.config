return {
  summary = 'Set the absorption coefficients.',
  description = [[
    Sets the global air absorption coefficients for the medium.  This affects Sources that have the
    `absorption` effect enabled, causing audio volume to drop off with distance as it is absorbed by
    the medium it's traveling through (air, water, etc.).  The difference between absorption and
    falloff is that absorption is more subtle and is frequency-dependent, so higher-frequency bands
    can get absorbed more quickly than lower ones.  This can be used to apply "underwater" effects
    and stuff.
  ]],
  arguments = {
    {
      name = 'low',
      type = 'number',
      description = 'The absorption coefficient for the low frequency band.'
    },
    {
      name = 'mid',
      type = 'number',
      description = 'The absorption coefficient for the mid frequency band.'
    },
    {
      name = 'high',
      type = 'number',
      description = 'The absorption coefficient for the high frequency band.'
    }
  },
  returns = {},
  notes = [[
    Absorption is currently only supported by the phonon spatializer.

    The frequency bands correspond to `400Hz`, `2.5KHz`, and `15KHz`.

    The default coefficients are `.0002`, `.0017`, and `.0182` for low, mid, and high.
  ]]
}
