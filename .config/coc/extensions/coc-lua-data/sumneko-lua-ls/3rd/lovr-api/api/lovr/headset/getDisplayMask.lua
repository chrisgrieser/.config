return {
  tag = 'headset',
  summary = 'Get a mesh that masks out the visible display area.',
  description = [[
    Returns 2D triangle vertices that represent areas of the headset display that will never be seen
    by the user (due to the circular lenses).  This area can be masked out by rendering it to the
    depth buffer or stencil buffer.  Then, further drawing operations can skip rendering those
    pixels using the depth test (`lovr.graphics.setDepthTest`) or stencil test
    (`lovr.graphics.setStencilTest`), which improves performance.
  ]],
  arguments = {},
  returns = {
    {
      name = 'points',
      type = 'table',
      description = 'A table of points.  Each point is a table with two numbers between 0 and 1.'
    }
  },
  example = [=[
    function lovr.load()
      lovr.graphics.setBackgroundColor(1, 1, 1)

      shader = lovr.graphics.newShader([[
        vec4 position(mat4 projection, mat4 transform, vec4 vertex) {

          // Rescale mesh coordinates from (0,1) to (-1,1)
          vertex.xy *= 2.;
          vertex.xy -= 1.;

          // Flip the mesh if it's being drawn in the right eye
          if (lovrViewID == 1) {
            vertex.x = -vertex.x;
          }

          return vertex;
        }
      ]], [[
        // The fragment shader returns solid black for illustration purposes.  It could be transparent.
        vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
          return vec4(0., 0., 0., 1.);
        }
      ]])

      mask = lovr.headset.getDisplayMask()

      if mask then
        mesh = lovr.graphics.newMesh({ { 'lovrPosition', 'float', 2 } }, mask, 'triangles')
      end
    end

    function lovr.draw()
      if mask then
        -- Mask out parts of the display that aren't visible to skip rendering those pixels later
        lovr.graphics.setShader(shader)
        mesh:draw()
        lovr.graphics.setShader()

        -- Draw a red cube
        lovr.graphics.setColor(0xff0000)
        lovr.graphics.cube('fill', 0, 1.7, -1, .5, lovr.timer.getTime())
        lovr.graphics.setColor(0xffffff)
      else
        lovr.graphics.setColor(0x000000)
        lovr.graphics.print('No mask found.', 0, 1.7, -3, .2)
        lovr.graphics.setColor(0xffffff)
      end
    end
  ]=],
  related = {
    'lovr.graphics.newMesh',
    'lovr.graphics.setDepthTest',
    'lovr.graphics.setStencilTest'
  }
}
