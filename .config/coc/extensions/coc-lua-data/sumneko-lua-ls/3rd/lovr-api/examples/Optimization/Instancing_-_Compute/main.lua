-- Surround yourself with monkeys and efficiently move them with compute shaders

ASSUME_FRAMERATE = 1/120

function lovr.load()
  MONKEYS = 500

  if not lovr.graphics.getFeatures().compute then
    error("This example requires compute shaders to run, but compute shaders are not supported on this machine.")
  end

  -- Create a ShaderBlock to store positions for lots of models
  block = lovr.graphics.newShaderBlock('compute', {
    modelTransforms = { 'mat4', MONKEYS },
    modelTransformsPerFrame = { 'mat4', MONKEYS }
  }, { usage = 'dynamic' }) -- "Dynamic" means "compute shaders can write to this"

  -- Write some random transforms to the block
  local random, randomNormal = lovr.math.random, lovr.math.randomNormal
  do
    local transforms = {}
    for i = 1, MONKEYS do
      local position = vec3(randomNormal(8), randomNormal(8), randomNormal(8))
      local orientation = quat(random(2 * math.pi), random(), random(), random())
      local scale = vec3(.75)
      transforms[i] = mat4(position, scale, orientation)
    end
    block:send('modelTransforms', transforms)
  end
  -- More random transforms-- this will correspond to the transform applied to each monkey per frame
  do
    local transforms = {}
    for i = 1, MONKEYS do
      local position = vec3(randomNormal(1), randomNormal(8), randomNormal(8)):mul(ASSUME_FRAMERATE)
      local radianSwing = ASSUME_FRAMERATE * math.pi / 2
      local orientation = quat(random(-radianSwing, radianSwing), random(), random(), random())
      local scale = vec3(1)
      transforms[i] = mat4(position, scale, orientation)
    end
    block:send('modelTransformsPerFrame', transforms)
  end

  -- Create the compute shader, we will run this once per frame
  computeShader = lovr.graphics.newComputeShader(
    string.format(block:getShaderCode('ModelBlock') .. [[
      #define MONKEYS %d
      layout(local_size_x = MONKEYS, local_size_y = 1, local_size_z = 1) in;
      void compute() {
        uint i = gl_LocalInvocationID.x;
        modelTransforms[i] = modelTransforms[i] * modelTransformsPerFrame[i];
      }
    ]], MONKEYS)
  )
  computeShader:sendBlock('ModelBlock', block)

  -- Create the display shader, injecting the shader code for the block
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

function lovr.update()
  lovr.graphics.compute(computeShader,1,1,1)
end

-- Draw many copies of the model using instancing, with transforms from the shader block
function lovr.draw()
  lovr.graphics.setShader(shader)
  model:draw(mat4(), MONKEYS)
  lovr.graphics.setShader()
end
