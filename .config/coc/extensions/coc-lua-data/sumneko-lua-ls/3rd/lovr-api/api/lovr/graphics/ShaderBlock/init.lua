return {
  summary = 'A big ol\' block of data that can be sent to a Shader.',
  description = [[
    ShaderBlocks are objects that can hold large amounts of data and can be sent to Shaders.  It is
    common to use "uniform" variables to send data to shaders, but uniforms are usually limited to
    a few kilobytes in size.  ShaderBlocks are useful for a few reasons:

    - They can hold a lot more data.
    - Shaders can modify the data in them, which is really useful for compute shaders.
    - Setting the data in a ShaderBlock updates the data for all Shaders using the block, so you
      don't need to go around setting the same uniforms in lots of different shaders.

    On systems that support compute shaders, ShaderBlocks can optionally be "writable".  A writable
    ShaderBlock is a little bit slower than a non-writable one, but shaders can modify its contents
    and it can be much, much larger than a non-writable ShaderBlock.
  ]],
  constructor = 'lovr.graphics.newShaderBlock',
  notes = [[
    - A Shader can use up to 8 ShaderBlocks.
    - ShaderBlocks can not contain textures.
    - Some systems have bugs with `vec3` variables in ShaderBlocks.  If you run into strange bugs,
      try switching to a `vec4` for the variable.
  ]],
  example = [=[
    function lovr.load()
      -- Create a ShaderBlock to store positions for 1000 models
      block = lovr.graphics.newShaderBlock('uniform', {
        modelPositions = { 'mat4', 1000 }
      }, { usage = 'static' })

      -- Write some random transforms to the block
      local transforms = {}
      for i = 1, 1000 do
        transforms[i] = lovr.math.mat4()
        local random, randomNormal = lovr.math.random, lovr.math.randomNormal
        transforms[i]:translate(randomNormal(8), randomNormal(8), randomNormal(8))
        transforms[i]:rotate(random(2 * math.pi), random(), random(), random())
      end
      block:send('modelPositions', transforms)

      -- Create the shader, injecting the shader code for the block
      shader = lovr.graphics.newShader(
        block:getShaderCode('ModelBlock') .. [[
        vec4 position(mat4 projecion, mat4 transform, vec4 vertex) {
          return projection * transform * modelPositions[gl_InstanceID] * vertex;
        }
      ]])

      -- Bind the block to the shader
      shader:sendBlock('ModelBlock', block)
      model = lovr.graphics.newModel('monkey.obj')
    end

    -- Draw the model 1000 times, using positions from the shader block
    function lovr.draw()
      lovr.graphics.setShader(shader)
      model:draw(lovr.math.mat4(), 1000)
      lovr.graphics.setShader()
    end
  ]=]
}
