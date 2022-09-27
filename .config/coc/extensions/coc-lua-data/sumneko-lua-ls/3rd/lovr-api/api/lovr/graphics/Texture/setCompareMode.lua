return {
  summary = 'Set the CompareMode for the Texture.',
  description = [[
    Sets the compare mode for a texture.  This is only used for "shadow samplers", which are uniform
    variables in shaders with type `sampler2DShadow`.  Sampling a shadow sampler uses a sort of
    virtual depth test, and the compare mode of the texture is used to control how the depth test is
    performed.
  ]],
  arguments = {
    {
      name = 'compareMode',
      type = 'CompareMode',
      default = 'nil',
      description = 'The new compare mode.  Use `nil` to disable the compare mode.'
    }
  },
  returns = {},
  related = {
    'lovr.graphics.setDepthTest'
  }
}
