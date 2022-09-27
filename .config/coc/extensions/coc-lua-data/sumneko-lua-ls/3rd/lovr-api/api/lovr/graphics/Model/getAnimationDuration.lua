return {
  summary = 'Get the duration of an animation in the Model.',
  description = 'Returns the duration of an animation in the Model, in seconds.',
  arguments = {
    name = {
      type = 'string',
      description = 'The name of the animation.'
    },
    index = {
      type = 'number',
      description = 'The animation index.'
    }
  },
  returns = {
    duration = {
      type = 'number',
      description = 'The duration of the animation, in seconds.'
    }
  },
  variants = {
    {
      arguments = { 'name' },
      returns = { 'duration' }
    },
    {
      arguments = { 'index' },
      returns = { 'duration' }
    }
  },
  related = {
    'Model:getAnimationCount',
    'Model:getAnimationName',
    'Model:animate'
  }
}
