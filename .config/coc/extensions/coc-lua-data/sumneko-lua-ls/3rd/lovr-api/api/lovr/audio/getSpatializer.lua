return {
  tag = 'listener',
  summary = 'Get the name of the active spatializer',
  description = [[
    Returns the name of the active spatializer (`simple`, `oculus`, or `phonon`).

    The `t.audio.spatializer` setting in `lovr.conf` can be used to express a preference for a
    particular spatializer.  If it's `nil`, all spatializers will be tried in the following order:
    `phonon`, `oculus`, `simple`.
  ]],
  arguments = {},
  returns = {
    {
      name = 'spatializer',
      type = 'string',
      description = 'The name of the active spatializer.'
    }
  },
  notes = [[
    Using a feature or effect that is not supported by the current spatializer will not error, it
    just won't do anything.

    <table>
      <thead>
        <tr>
          <td>Feature</td>
          <td>simple</td>
          <td>phonon</td>
          <td>oculus</td>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>Effect: Spatialization</td>
          <td>x</td>
          <td>x</td>
          <td>x</td>
        </tr>
        <tr>
          <td>Effect: Attenuation</td>
          <td>x</td>
          <td>x</td>
          <td></td>
        </tr>
        <tr>
          <td>Effect: Absorption</td>
          <td></td>
          <td>x</td>
          <td></td>
        </tr>
        <tr>
          <td>Effect: Occlusion</td>
          <td></td>
          <td>x</td>
          <td></td>
        </tr>
        <tr>
          <td>Effect: Transmission</td>
          <td></td>
          <td>x</td>
          <td></td>
        </tr>
        <tr>
          <td>Effect: Reverb</td>
          <td></td>
          <td>x</td>
          <td></td>
        </tr>
        <tr>
          <td>lovr.audio.setGeometry</td>
          <td></td>
          <td>x</td>
          <td></td>
        </tr>
        <tr>
          <td>Source:setDirectivity</td>
          <td>x</td>
          <td>x</td>
          <td></td>
        </tr>
        <tr>
          <td>Source:setRadius</td>
          <td></td>
          <td>x</td>
          <td></td>
        </tr>
      </tbody>
    </table>
  ]],
  related = {
    'lovr.conf'
  }
}
