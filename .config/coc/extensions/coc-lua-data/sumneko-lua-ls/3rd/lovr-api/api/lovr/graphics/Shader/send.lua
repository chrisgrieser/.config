return {
  summary = 'Update a uniform variable in the Shader.',
  description = 'Updates a uniform variable in the Shader.',
  arguments = {
    {
      name = 'uniform',
      type = 'string',
      description = 'The name of the uniform to update.'
    },
    {
      name = 'value',
      type = '*',
      description = 'The new value of the uniform.'
    }
  },
  returns = {
    {
      name = 'success',
      type = 'boolean',
      description = 'Whether the uniform exists and was updated.'
    }
  },
  notes = [[
    The shader does not need to be active to update its uniforms.

    The following type combinations are supported:

    <table>
      <thead>
        <tr>
          <td>Uniform type</td>
          <td>LÖVR type</td>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td>float</td>
          <td>number</td>
        </tr>
        <tr>
          <td>int</td>
          <td>number</td>
        </tr>
        <tr>
          <td>vec2</td>
          <td>{ x, y }</td>
        </tr>
        <tr>
          <td>vec3</td>
          <td>{ x, y, z } or vec3</td>
        </tr>
        <tr>
          <td>vec4</td>
          <td>{ x, y, z, w }</td>
        </tr>
        <tr>
          <td>ivec2</td>
          <td>{ x, y }</td>
        </tr>
        <tr>
          <td>ivec3</td>
          <td>{ x, y, z }</td>
        </tr>
        <tr>
          <td>ivec4</td>
          <td>{ x, y, z, w }</td>
        </tr>
        <tr>
          <td>mat2</td>
          <td>{ x, ... }</td>
        </tr>
        <tr>
          <td>mat3</td>
          <td>{ x, ... }</td>
        </tr>
        <tr>
          <td>mat4</td>
          <td>{ x, ... } or mat4</td>
        </tr>
        <tr>
          <td>sampler</td>
          <td>Texture</td>
        </tr>
        <tr>
          <td>image</td>
          <td>Texture</td>
        </tr>
      </tbody>
    </table>

    Uniform arrays can be wrapped in tables or passed as multiple arguments.

    Textures must match the type of sampler or image they are being sent to.

    The following sampler (and image) types are currently supported:

    - `sampler2D`
    - `sampler3D`
    - `samplerCube`
    - `sampler2DArray`

    `Blob`s can be used to pass arbitrary binary data to Shader variables.
  ]],
  example = {
    description = 'Updating a `vec3` uniform:',
    code = [=[
      function lovr.load()
        shader = lovr.graphics.newShader([[
          uniform vec3 offset;
          vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
            vertex.xyz += offset;
            return projection * transform * vertex;
          }
        ]], nil)

        shader:send('offset', { .3, .7, 0 })
      end
    ]=]
  },
  related = {
    'Shader:hasUniform',
    'ShaderBlock:send',
    'Shader:sendBlock'
  }
}
