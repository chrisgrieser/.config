function lovr.load()
  sbsTexture = lovr.graphics.newTexture('sbs_left_right.png', { mipmaps = false })
  sbsShader = lovr.graphics.newShader([[
    vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
      return projection * transform * vertex;
    }
  ]], [[
    uniform sampler2D tex;
    vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
      vec2 newUV = clamp(uv, 0., 1.) * vec2(.5, 1.) + vec2(lovrViewID) * vec2(.5, 0.);

      // Use this instead for top-bottom stereo
      // vec2 newUV = clamp(uv, 0., 1.) * vec2(1., .5) + vec2(lovrViewID) * vec2(0., .5);

      return texture(tex, newUV);
    }
  ]], {
    flags = {
      highp = true
    }
  })

  lovr.graphics.setBackgroundColor(.05, .05, .05)
end

function lovr.draw()
  lovr.graphics.setShader(sbsShader)
  sbsShader:send('tex', sbsTexture)
  lovr.graphics.plane('fill', 0, 1, -2, 2.5, 2, 0, 0, 0, 0)
end
