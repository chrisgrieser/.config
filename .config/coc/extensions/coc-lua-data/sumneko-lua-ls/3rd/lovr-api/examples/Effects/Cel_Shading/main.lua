function lovr.load()
  shader = lovr.graphics.newShader([[
    out vec3 vNormal;
    vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
      vNormal = lovrNormalMatrix * lovrNormal;
      return projection * transform * vertex;
    }
  ]], [[
    #define BANDS 8.0
    const vec3 lightDirection = vec3(-1., -1., -1.);
    in vec3 vNormal;

    vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
      vec3 L = normalize(-lightDirection);
      vec3 N = normalize(vNormal);
      float normal = .5 + dot(N, L) * .5;

      vec3 baseColor = graphicsColor.rgb * normal;
      vec3 clampedColor = round(baseColor * BANDS) / BANDS;

      return vec4(clampedColor, graphicsColor.a);
    }
  ]])
end

function lovr.draw()
  lovr.graphics.setShader(shader)

  lovr.graphics.setColor(0, 0, 1)
  lovr.graphics.sphere(0, 1.7, -1, .15)

  lovr.graphics.setColor(0, 1, 0)
  lovr.graphics.sphere(-.4, 1.7, -1, .15)

  lovr.graphics.setColor(1, 0, 0)
  lovr.graphics.sphere(.4, 1.7, -1, .15)

  lovr.graphics.setShader()
end
