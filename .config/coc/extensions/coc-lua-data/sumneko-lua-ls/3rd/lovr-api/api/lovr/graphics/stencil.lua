return {
  tag = 'graphicsPrimitives',
  summary = 'Modify the stencil buffer.',
  description = 'Renders to the stencil buffer using a function.',
  arguments = {
    callback = {
      type = 'function',
      arguments = {},
      returns = {},
      description = 'The function that will be called to render to the stencil buffer.'
    },
    action = {
      type = 'StencilAction',
      default = [['replace']],
      description = 'How to modify the stencil value of pixels that are rendered to.'
    },
    value = {
      type = 'number',
      default = '1',
      description = 'If `action` is "replace", this is the value that pixels are replaced with.'
    },
    keep = {
      type = 'boolean',
      default = 'false',
      description = 'If false, the stencil buffer will be cleared to zero before rendering.'
    },
    initial = {
      type = 'number',
      default = '0',
      description = 'The value to clear the stencil buffer to before rendering.'
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'callback', 'action', 'value', 'keep' },
      returns = {}
    },
    {
      arguments = { 'callback', 'action', 'value', 'initial' },
      returns = {}
    }
  },
  notes = 'Stencil values are between 0 and 255.',
  related = {
    'lovr.graphics.getStencilTest',
    'lovr.graphics.setStencilTest'
  }
}
