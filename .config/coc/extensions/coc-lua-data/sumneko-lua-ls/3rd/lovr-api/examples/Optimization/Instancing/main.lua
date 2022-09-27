-- Surround yourself with monkeys, efficiently

function lovr.load()
  MONKEYS = 500

  -- Create a ShaderBlock to store positions for lots of models
  block = lovr.graphics.newShaderBlock('uniform', {
    modelTransforms = { 'mat4', MONKEYS }
  }, { usage = 'static' })

  -- Write some random transforms to the block
  local transforms = {}
  local random, randomNormal = lovr.math.random, lovr.math.randomNormal
  for i = 1, MONKEYS do
    local position = vec3(randomNormal(8), randomNormal(8), randomNormal(8))
    local orientation = quat(random(2 * math.pi), random(), random(), random())
    local scale = vec3(.75)
    transforms[i] = mat4(position, scale, orientation)
  end
  block:send('modelTransforms', transforms)

  -- Create the shader, injecting the shader code for the block
  shader = lovr.graphics.newShader(
    block:getShaderCode('ModelBlock') .. [[
    out vec3 vNormal;
    vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
      vNormal = lovrNormal;
      return projection * transform * modelTransforms[lovrInstanceID] * vertex;
    }
  ]], [[
    in vec3 vNormal;
    vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
      return vec4(vNormal * .5 + .5, 1.);
    }
  ]])

  -- Bind the block to the shader
  shader:sendBlock('ModelBlock', block)

  model = lovr.graphics.newModel('monkey.obj')
  lovr.graphics.setCullingEnabled(true)
  lovr.graphics.setBlendMode(nil)
end

-- Draw many copies of the model using instancing, with transforms from the shader block
function lovr.draw()
  lovr.graphics.setShader(shader)
  model:draw(mat4(), MONKEYS)
  lovr.graphics.setShader()
end
