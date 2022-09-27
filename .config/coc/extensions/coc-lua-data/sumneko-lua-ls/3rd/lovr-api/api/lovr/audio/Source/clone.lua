return {
  tag = 'sourceUtility',
  summary = 'Create an identical copy of the Source.',
  description = [[
    Creates a copy of the Source, referencing the same `Sound` object and inheriting all of the
    settings of this Source.  However, it will be created in the stopped state and will be rewound to
    the beginning.
  ]],
  arguments = {},
  returns = {
    {
      name = 'source',
      type = 'Source',
      description = 'A genetically identical copy of the Source.'
    }
  },
  notes = [[
    This is a good way to create multiple Sources that play the same sound, since the audio data
    won't be loaded multiple times and can just be reused.  You can also create multiple `Source`
    objects and pass in the same `Sound` object for each one, which will have the same effect.
  ]],
  related = {
    'lovr.audio.newSource'
  }
}
