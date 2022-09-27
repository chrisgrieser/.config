return {
  tag = 'graphicsObjects',
  summary = 'Create a new compute Shader.',
  description = [[
    Creates a new compute Shader, used for running generic compute operations on the GPU.
  ]],
  arguments = {
    {
      name = 'source',
      type = 'string',
      description = 'The code or filename of the compute shader.'
    },
    {
      name = 'options',
      type = 'table',
      default = '{}',
      description = 'Optional settings for the Shader.',
      table = {
        {
          name = 'flags',
          type = 'table',
          default = '{}',
          description = 'A table of key-value options passed to the Shader.'
        }
      }
    }
  },
  returns = {
    {
      name = 'shader',
      type = 'Shader',
      description = 'The new compute Shader.'
    }
  },
  notes = [[
    Compute shaders are not supported on all hardware, use `lovr.graphics.getFeatures` to check if
    they're available on the current system.

    The source code for a compute shader needs to implement the `void compute();` GLSL function.
    This function doesn't return anything, but the compute shader is able to write data out to
    `Texture`s or `ShaderBlock`s.

    The GLSL version used for compute shaders is GLSL 430.

    Currently, up to 32 shader flags are supported.
  ]],
  example = [=[
    function lovr.load()
      computer = lovr.graphics.newComputeShader([[
        layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

        void compute() {
          // compute things!?
        }
      ]])

      -- Run the shader 4 times
      local width, height, depth = 4, 1, 1

      -- Dispatch the compute operation
      lovr.graphics.compute(computer, width, height, depth)
    end
  ]=],
  related = {
    'lovr.graphics.compute',
    'lovr.graphics.newShader',
    'lovr.graphics.setShader',
    'lovr.graphics.getShader'
  }
}
