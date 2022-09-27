return {
  summary = 'Check if a Model has joints.',
  description = [[
    Returns whether the Model has any nodes associated with animated joints.  This can be used to
    approximately determine whether an animated shader needs to be used with an arbitrary Model.
  ]],
  arguments = {},
  returns = {
    {
      name = 'skeletal',
      type = 'boolean',
      description = 'Whether the Model has any nodes that use skeletal animation.'
    }
  },
  notes = [[
    A model can still be animated even if this function returns false, since node transforms can
    still be animated with keyframes without skinning.  These types of animations don't need to use
    a Shader with the `animated = true` flag, though.
  ]],
  related = {
    'Model:getAnimationCount',
    'lovr.graphics.newShader'
  }
}
