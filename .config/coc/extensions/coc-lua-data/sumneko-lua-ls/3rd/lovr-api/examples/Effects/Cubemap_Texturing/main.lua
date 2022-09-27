-- Texture from Humus (www.humus.name)

function lovr.load()
  cube = lovr.graphics.newTexture({
    left = 'negx.jpg',
    right = 'posx.jpg',
    top = 'posy.jpg',
    bottom = 'negy.jpg',
    front = 'negz.jpg',
    back = 'posz.jpg'
  })

  shader = lovr.graphics.newShader([[
    out vec3 pos;
    vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
      pos = vertex.xyz;
      return projection * transform * vertex;
    }
  ]], [[
    uniform samplerCube cube;
    in vec3 pos;
    vec4 color(vec4 tint, sampler2D image, vec2 uv) {
      return texture(cube, pos);
    }
  ]])

  shader:send('cube', cube)
end

function lovr.draw()
  lovr.graphics.setShader(shader)
  lovr.graphics.cube('fill', 0, 1.7, -3, 1, lovr.timer.getTime(), 1, 1, 1)
  lovr.graphics.setShader()
end
