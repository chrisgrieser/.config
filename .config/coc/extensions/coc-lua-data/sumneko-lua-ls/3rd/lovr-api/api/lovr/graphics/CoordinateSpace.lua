return {
  description = 'Different coordinate spaces for nodes in a Model.',
  values = {
    {
      name = 'local',
      description = 'The coordinate space relative to the node\'s parent.'
    },
    {
      name = 'global',
      description = 'The coordinate space relative to the root node of the Model.'
    }
  },
  related = {
    'Model:pose'
  }
}
