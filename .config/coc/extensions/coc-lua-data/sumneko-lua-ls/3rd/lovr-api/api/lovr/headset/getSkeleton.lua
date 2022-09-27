return {
  tag = 'input',
  summary = 'Get skeletal joint poses tracked by a device.',
  description = [[
    Returns a list of joint poses tracked by a device.  Currently, only hand devices are able to
    track joints.
  ]],
  arguments = {
    device = {
      type = 'Device',
      description = 'The Device to query.'
    },
    t = {
      type = 'table',
      description = 'A table to fill with the joint poses, instead of allocating a new one.'
    }
  },
  returns = {
    poses = {
      type = 'table',
      description = [[
        A list of joint poses for the device.  Each pose is a table with 3 numbers for the position
        of the joint followed by 4 numbers for the angle/axis orientation of the joint.
      ]]
    }
  },
  variants = {
    {
      arguments = { 'device' },
      returns = { 'poses' }
    },
    {
      arguments = { 'device', 't' },
      returns = { 'poses' }
    }
  },
  notes = [[
    If the Device does not support tracking joints or the poses are unavailable, `nil` is returned.

    The joint orientation is similar to the graphics coordinate system: -Z is the forwards
    direction, pointing towards the fingertips.  The +Y direction is "up", pointing out of the back
    of the hand.  The +X direction is to the right, perpendicular to X and Z.

    Hand joints are returned in the following order:

    <table>
      <thead>
        <tr>
          <td colspan="2">Joint</td>
          <td>Index</td>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td colspan="2">Palm</td>
          <td>1</td>
        </tr>
        <tr>
          <td colspan="2">Wrist</td>
          <td>2</td>
        </tr>
        <tr>
          <td rowspan="4">Thumb</td>
          <td>Metacarpal</td>
          <td>3</td>
        </tr>
        <tr>
          <td>Proximal</td>
          <td>4</td>
        </tr>
        <tr>
          <td>Distal</td>
          <td>5</td>
        </tr>
        <tr>
          <td>Tip</td>
          <td>6</td>
        </tr>
        <tr>
          <td rowspan="5">Index</td>
          <td>Metacarpal</td>
          <td>7</td>
        </tr>
        <tr>
          <td>Proximal</td>
          <td>8</td>
        </tr>
        <tr>
          <td>Intermediate</td>
          <td>9</td>
        </tr>
        <tr>
          <td>Distal</td>
          <td>10</td>
        </tr>
        <tr>
          <td>Tip</td>
          <td>11</td>
        </tr>
        <tr>
          <td rowspan="5">Middle</td>
          <td>Metacarpal</td>
          <td>12</td>
        </tr>
        <tr>
          <td>Proximal</td>
          <td>13</td>
        </tr>
        <tr>
          <td>Intermediate</td>
          <td>14</td>
        </tr>
        <tr>
          <td>Distal</td>
          <td>15</td>
        </tr>
        <tr>
          <td>Tip</td>
          <td>16</td>
        </tr>
        <tr>
          <td rowspan="5">Ring</td>
          <td>Metacarpal</td>
          <td>17</td>
        </tr>
        <tr>
          <td>Proximal</td>
          <td>18</td>
        </tr>
        <tr>
          <td>Intermediate</td>
          <td>19</td>
        </tr>
        <tr>
          <td>Distal</td>
          <td>20</td>
        </tr>
        <tr>
          <td>Tip</td>
          <td>21</td>
        </tr>
        <tr>
          <td rowspan="5">Pinky</td>
          <td>Metacarpal</td>
          <td>22</td>
        </tr>
        <tr>
          <td>Proximal</td>
          <td>23</td>
        </tr>
        <tr>
          <td>Intermediate</td>
          <td>24</td>
        </tr>
        <tr>
          <td>Distal</td>
          <td>25</td>
        </tr>
        <tr>
          <td>Tip</td>
          <td>26</td>
        </tr>
      </tbody>
    </table>
  ]],
  example = [[
    function lovr.draw()
      for _, hand in ipairs({ 'left', 'right' }) do
        for _, joint in ipairs(lovr.headset.getSkeleton(hand) or {}) do
          lovr.graphics.points(unpack(joint, 1, 3))
        end
      end
    end
  ]],
  related = {
    'lovr.headset.getPose',
    'lovr.headset.animate'
  }
}
