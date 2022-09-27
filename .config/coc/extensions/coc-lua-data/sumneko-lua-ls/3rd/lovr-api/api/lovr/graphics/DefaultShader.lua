return {
  summary = 'The set of builtin shaders.',
  description = [[
    The following shaders are built in to LÖVR, and can be used as an argument to
    `lovr.graphics.newShader` instead of providing raw GLSL shader code.  The shaders can be further
    customized by using the `flags` argument.  If you pass in `nil` to `lovr.graphics.setShader`,
    LÖVR will automatically pick a DefaultShader to use based on whatever is being drawn.
  ]],
  values = {
    {
      name = 'unlit',
      description = 'A simple shader without lighting, using only colors and a diffuse texture.'
    },
    {
      name = 'standard',
      description = 'A physically-based rendering (PBR) shader, using advanced material properties.'
    },
    {
      name = 'cube',
      description = 'A shader that renders a cubemap texture.'
    },
    {
      name = 'pano',
      description = 'A shader that renders a 2D equirectangular texture with spherical coordinates.'
    },
    {
      name = 'font',
      description = 'A shader that renders font glyphs.'
    },
    {
      name = 'fill',
      description = [[
        A shader that passes its vertex coordinates unmodified to the fragment shader, used to
        render view-independent fixed geometry like fullscreen quads.
      ]]
    }
  }
}
