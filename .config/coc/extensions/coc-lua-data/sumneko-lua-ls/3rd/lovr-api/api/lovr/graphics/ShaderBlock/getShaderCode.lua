return {
  summary = 'Get a GLSL string that defines the ShaderBlock in a Shader.',
  description = [[
    Before a ShaderBlock can be used in a Shader, the Shader has to have the block's variables
    defined in its source code.  This can be a tedious process, so you can call this function to
    return a GLSL string that contains this definition.  Roughly, it will look something like this:

        layout(std140) uniform <label> {
          <type> <name>[<count>];
        } <namespace>;
  ]],
  arguments = {
    {
      name = 'label',
      type = 'string',
      description = [[
        The label of the block in the shader code.  This will be used to identify it when using
        `Shader:sendBlock`.
      ]]
    },
    {
      name = 'namespace',
      type = 'string',
      default = 'nil',
      description = [[
        The namespace to use when accessing the block's variables in the shader code.  This can be
        used to prevent naming conflicts if two blocks have variables with the same name.  If the
        namespace is nil, the block's variables will be available in the global scope.
      ]]
    }
  },
  returns = {
    {
      name = 'code',
      type = 'string',
      description = 'The code that can be prepended to `Shader` code.'
    }
  },
  example = [=[
    block = lovr.graphics.newShaderBlock('uniform', {
      sizes = { 'float', 10 }
    })

    code = [[
      #ifdef VERTEX
        ]] .. block:getShaderCode('MyBlock', 'sizeBlock') .. [[

        // vertex shader goes here,
        // it can access sizeBlock.sizes
      #endif

      #ifdef PIXEL
        // fragment shader goes here
      #endif
    ]]

    shader = lovr.graphics.newShader(code, code)
    shader:sendBlock('MyBlock', block)
  ]=],
  related = {
    'lovr.graphics.newShader',
    'lovr.graphics.newComputeShader'
  }
}
