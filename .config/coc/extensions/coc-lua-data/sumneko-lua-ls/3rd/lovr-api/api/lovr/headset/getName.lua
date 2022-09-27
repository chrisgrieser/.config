return {
  tag = 'headset',
  summary = 'Get the name of the connected headset display.',
  description = [[
    Returns the name of the headset as a string.  The exact string that is returned depends on the
    hardware and VR SDK that is currently in use.
  ]],
  arguments = {},
  returns = {
    {
      name = 'name',
      type = 'string',
      description = 'The name of the headset as a string.'
    }
  },
  notes = [[
    <table>
      <thead>
        <tr>
          <td>driver</td>
          <td>name</td>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>desktop</td>
          <td><code>Simulator</code></td>
        </tr>
        <tr>
          <td>openvr</td>
          <td>varies</td>
        </tr>
        <tr>
          <td>openxr</td>
          <td>varies</td>
        </tr>
        <tr>
          <td>vrapi</td>
          <td><code>Oculus Quest</code> or <code>Oculus Quest 2</code></td>
        </tr>
        <tr>
          <td>webxr</td>
          <td>always nil</td>
        </tr>
        <tr>
          <td>oculus</td>
          <td>varies</td>
        </tr>
        <tr>
          <td>pico</td>
          <td><code>Pico</code></td>
        </tr>
      </tbody>
    </table>
  ]]
}
