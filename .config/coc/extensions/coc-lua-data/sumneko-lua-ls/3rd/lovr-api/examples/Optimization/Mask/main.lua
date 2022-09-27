function lovr.load()
  lovr.graphics.setBackgroundColor(1, 1, 1)
  mask = lovr.headset.getDisplayMask()

  -- Print the mesh, for debugging
  if mask then
    print('mask = {')
    for i = 1, #mask do
      print(string.format('\t{ %f, %f }', mask[i][1], mask[i][2]))
    end
    print('}')
  else
    print('No mask found')
  end

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
