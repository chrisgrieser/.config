return {
  summary = 'Get the number of mipmap levels of the Texture.',
  description = 'Returns the number of mipmap levels of the Texture.',
  arguments = {},
  returns = {
    {
      name = 'mipmaps',
      type = 'number',
      description = 'The number of mipmap levels in the Texture.'
    }
  },
  related = {
    'Texture:getWidth',
    'Texture:getHeight',
    'Texture:getDepth',
    'Texture:getDimensions',
    'lovr.graphics.newTexture'
  }
}
