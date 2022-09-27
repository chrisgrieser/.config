return {
  summary = 'A GLSL program used for low-level control over rendering.',
  description = [[
    Shaders are GLSL programs that transform the way vertices and pixels show up on the screen.
    They can be used for lighting, postprocessing, particles, animation, and much more.  You can use
    `lovr.graphics.setShader` to change the active Shader.
  ]],
  constructors = {
    'lovr.graphics.newShader',
    'lovr.graphics.newComputeShader'
  },
  notes = [[
    GLSL version `330` is used on desktop systems, and `300 es` on WebGL/Android.

    The default vertex shader:

        vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
          return projection * transform * vertex;
        }

    The default fragment shader:

        vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
          return graphicsColor * lovrDiffuseColor * lovrVertexColor * texture(image, uv);
        }

    Additionally, the following headers are prepended to the shader source, giving you convenient
    access to a default set of uniform variables and vertex attributes.

    Vertex shader header:

        in vec3 lovrPosition; // The vertex position
        in vec3 lovrNormal; // The vertex normal vector
        in vec2 lovrTexCoord;
        in vec4 lovrVertexColor;
        in vec3 lovrTangent;
        in uvec4 lovrBones;
        in vec4 lovrBoneWeights;
        in uint lovrDrawID;
        out vec4 lovrGraphicsColor;
        uniform mat4 lovrModel;
        uniform mat4 lovrView;
        uniform mat4 lovrProjection;
        uniform mat4 lovrTransform; // Model-View matrix
        uniform mat3 lovrNormalMatrix; // Inverse-transpose of lovrModel
        uniform mat3 lovrMaterialTransform;
        uniform float lovrPointSize;
        uniform mat4 lovrPose[48];
        uniform int lovrViewportCount;
        uniform int lovrViewID;
        const mat4 lovrPoseMatrix; // Bone-weighted pose
        const int lovrInstanceID; // Current instance ID

    Fragment shader header:

        in vec2 lovrTexCoord;
        in vec4 lovrVertexColor;
        in vec4 lovrGraphicsColor;
        out vec4 lovrCanvas[gl_MaxDrawBuffers];
        uniform float lovrMetalness;
        uniform float lovrRoughness;
        uniform vec4 lovrDiffuseColor;
        uniform vec4 lovrEmissiveColor;
        uniform sampler2D lovrDiffuseTexture;
        uniform sampler2D lovrEmissiveTexture;
        uniform sampler2D lovrMetalnessTexture;
        uniform sampler2D lovrRoughnessTexture;
        uniform sampler2D lovrOcclusionTexture;
        uniform sampler2D lovrNormalTexture;
        uniform samplerCube lovrEnvironmentTexture;
        uniform int lovrViewportCount;
        uniform int lovrViewID;

    ### Compute Shaders

    Compute shaders can be created with `lovr.graphics.newComputeShader` and run with
    `lovr.graphics.compute`.  Currently, compute shaders are written with raw GLSL.  There is no
    default compute shader, instead the `void compute();` function must be implemented.

    You can use the `layout` qualifier to specify a local work group size:

        layout(local_size_x = X, local_size_y = Y, local_size_z = Z) in;

    And the following built in variables can be used:

        in uvec3 gl_NumWorkGroups;       // The size passed to lovr.graphics.compute
        in uvec3 gl_WorkGroupSize;       // The local work group size
        in uvec3 gl_WorkGroupID;         // The current global work group
        in uvec3 gl_LocalInvocationID;   // The current local work group
        in uvec3 gl_GlobalInvocationID;  // A unique ID combining the global and local IDs
        in uint gl_LocalInvocationIndex; // A 1D index of the LocalInvocationID

    Compute shaders don't return anything but they can write data to `Texture`s or `ShaderBlock`s.
    To bind a texture in a way that can be written to a compute shader, declare the uniforms with a
    type of `image2D`, `imageCube`, etc. instead of the usual `sampler2D` or `samplerCube`.  Once a
    texture is bound to an image uniform, you can use the `imageLoad` and `imageStore` GLSL
    functions to read and write pixels in the image.  Variables in `ShaderBlock`s can be written to
    using assignment syntax.

    LÖVR handles synchronization of textures and shader blocks so there is no need to use manual
    memory barriers to synchronize writes to resources from compute shaders.
  ]],
  example = {
    description = 'Set a simple shader that colors pixels based on vertex normals.',
    code = [=[
      function lovr.load()
        lovr.graphics.setShader(lovr.graphics.newShader([[
          out vec3 vNormal; // This gets passed to the fragment shader

          vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
            vNormal = lovrNormal;
            return projection * transform * vertex;
          }
        ]], [[
          in vec3 vNormal; // This gets passed from the vertex shader

          vec4 color(vec4 gcolor, sampler2D image, vec2 uv) {
            return vec4(vNormal * .5 + .5, 1.0);
          }
        ]]))

        model = lovr.graphics.newModel('model.gltf')
      end

      function lovr.draw()
        model:draw(x, y, z)
      end
    ]=]
  },
  related = {
    'lovr.graphics.newComputeShader',
    'lovr.graphics.setShader',
    'lovr.graphics.getShader'
  }
}
