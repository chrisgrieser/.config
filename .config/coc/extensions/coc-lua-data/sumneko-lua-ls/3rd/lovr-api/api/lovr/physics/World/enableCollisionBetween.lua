return {
  tag = 'worldCollision',
  summary = 'Enable collision between two tags.',
  description = 'Enables collision between two collision tags.',
  arguments = {
    {
      name = 'tag1',
      type = 'string',
      description = 'The first tag.'
    },
    {
      name = 'tag2',
      type = 'string',
      description = 'The second tag.'
    }
  },
  returns = {},
  notes = [[
    Tags must be set up when creating the World, see `lovr.physics.newWorld`.

    By default, collision is enabled between all tags.
  ]],
  related = {
    'lovr.physics.newWorld',
    'World:disableCollisionBetween',
    'World:isCollisionEnabledBetween'
  }
}
