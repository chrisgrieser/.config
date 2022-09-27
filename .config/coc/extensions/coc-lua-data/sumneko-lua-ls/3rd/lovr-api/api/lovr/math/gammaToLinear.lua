return {
  tag = 'mathOther',
  summary = '	Convert a color from gamma space to linear space.',
  description = 'Converts a color from gamma space to linear space.',
  arguments = {
    gr = {
      type = 'number',
      description = 'The red component of the gamma-space color.'
    },
    gg = {
      type = 'number',
      description = 'The green component of the gamma-space color.'
    },
    gb = {
      type = 'number',
      description = 'The blue component of the gamma-space color.'
    },
    color = {
      type = 'table',
      description = 'A table containing the components of a gamma-space color.'
    },
    x = {
      type = 'number',
      description = 'The color channel to convert.'
    }
  },
  returns = {
    lr = {
      type = 'number',
      description = 'The red component of the resulting linear-space color.'
    },
    lg = {
      type = 'number',
      description = 'The green component of the resulting linear-space color.'
    },
    lb = {
      type = 'number',
      description = 'The blue component of the resulting linear-space color.'
    },
    y = {
      type = 'number',
      description = 'The converted color channel.'
    }
  },
  variants = {
    {
      arguments = { 'gr', 'gg', 'gb' },
      returns = { 'lr', 'lg', 'lb' }
    },
    {
      description = 'A table can also be used.',
      arguments = { 'color' },
      returns = { 'lr', 'lg', 'lb' }
    },
    {
      description = 'Convert a single color channel.',
      arguments = { 'x' },
      returns = { 'y' }
    }
  },
  related = {
    'lovr.math.linearToGamma'
  }
}
