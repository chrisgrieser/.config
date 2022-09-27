return {
  summary = 'Different depth test modes.',
  description = [[
    The method used to compare z values when deciding how to overlap rendered objects.  This is
    called the "depth test", and it happens on a pixel-by-pixel basis every time new objects are
    drawn.  If the depth test "passes" for a pixel, then the pixel color will be replaced by the
    new color and the depth value in the depth buffer will be updated.  Otherwise, the pixel will
    not be changed and the depth value will not be updated.
  ]],
  values = {
    {
      name = 'equal',
      description = 'The depth test passes when the depth values are equal.',
    },
    {
      name = 'notequal',
      description = 'The depth test passes when the depth values are not equal.',
    },
    {
      name = 'less',
      description = 'The depth test passes when the new depth value is less than the existing one.',
    },
    {
      name = 'lequal',
      description = [[
        The depth test passes when the new depth value is less than or equal to the existing one.
      ]],
    },
    {
      name = 'gequal',
      description = [[
        The depth test passes when the new depth value is greater than or equal to the existing one.
      ]],
    },
    {
      name = 'greater',
      description = [[
        The depth test passes when the new depth value is greater than the existing one.
      ]]
    }
  },
  related = {
    'lovr.graphics.getDepthTest',
    'lovr.graphics.setDepthTest',
    'lovr.graphics.getStencilTest',
    'lovr.graphics.setStencilTest'
  }
}
