local terrain, shader

local shaderCode = {[[
/* VERTEX shader */
out vec4 fragmentView;
uniform sampler2D heightmap;

vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
  vertex.z = texture(heightmap, vertex.xy).r / 10.;
  fragmentView = projection * transform * vertex;
  return fragmentView;
} ]], [[
/* FRAGMENT shader */
#define PI 3.1415926538
in vec4 fragmentView;
uniform vec3 fogColor;

vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv)
{
  float fogAmount = atan(length(fragmentView) * 0.1) * 2.0 / PI;
  vec4 color = vec4(mix(graphicsColor.rgb, fogColor, fogAmount), graphicsColor.a);
  return color;
}]]}

local function grid(subdivisions)
  local size = 1 / math.floor(subdivisions or 1)
  local vertices = {}
  local indices  = {}
  for y = -0.5, 0.5, size do
    for x = -0.5, 0.5, size do
      table.insert(vertices, {x, y, 0})
      table.insert(vertices, {x, y + size, 0})
      table.insert(vertices, {x + size, y, 0})
      table.insert(vertices, {x + size, y + size, 0})
      table.insert(indices, #vertices - 3)
      table.insert(indices, #vertices - 2)
      table.insert(indices, #vertices - 1)
      table.insert(indices, #vertices - 2)
      table.insert(indices, #vertices)
      table.insert(indices, #vertices - 1)
    end
  end
  local meshFormat = {{'lovrPosition', 'float', 3}}
  local mesh = lovr.graphics.newMesh(meshFormat, vertices, "triangles", "dynamic", true)
  mesh:setVertexMap(indices)
  return mesh
end

function lovr.load()
  local skyColor = {0.208, 0.208, 0.275}
  lovr.graphics.setBackgroundColor(skyColor)
  lovr.graphics.setLineWidth(5)
  heightmap = lovr.graphics.newTexture('heightmap.png')
  shader = lovr.graphics.newShader(unpack(shaderCode))
  shader:send('fogColor', { lovr.math.gammaToLinear(unpack(skyColor)) })
  shader:send('heightmap', heightmap)
  terrain = grid(100)
end

function lovr.draw()
  lovr.graphics.setShader(shader)
  lovr.graphics.rotate(math.pi/2, 1, 0, 0)
  lovr.graphics.scale(100)
  lovr.graphics.setColor(0.565, 0.404, 0.463)
  terrain:draw()
  lovr.graphics.setWireframe(true)
  lovr.graphics.setColor(0.388, 0.302, 0.412, 0.1)
  terrain:draw()
  lovr.graphics.setWireframe(false)
end
