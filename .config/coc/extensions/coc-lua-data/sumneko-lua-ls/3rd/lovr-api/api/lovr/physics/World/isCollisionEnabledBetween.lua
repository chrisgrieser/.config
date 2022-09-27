return {
  tag = 'worldCollision',
  summary = 'Check if two tags can collide.',
  description = 'Returns whether collisions are currently enabled between two tags.',
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
  returns = {
    {
      name = 'enabled',
      type = 'boolean',
      description = 'Whether or not two colliders with the specified tags will collide.'
    }
  },
  notes = [[
    Tags must be set up when creating the World, see `lovr.physics.newWorld`.

    By default, collision is enabled between all tags.
  ]],
  related = {
    'lovr.physics.newWorld',
    'World:disableCollisionBetween',
    'World:enableCollisionBetween'
  }
}
