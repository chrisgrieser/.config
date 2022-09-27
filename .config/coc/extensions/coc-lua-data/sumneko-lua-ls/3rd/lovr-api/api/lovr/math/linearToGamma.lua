return {
  tag = 'mathOther',
  summary = '	Convert a color from linear space to gamma space.',
  description = 'Converts a color from linear space to gamma space.',
  arguments = {
    lr = {
      type = 'number',
      description = 'The red component of the linear-space color.'
    },
    lg = {
      type = 'number',
      description = 'The green component of the linear-space color.'
    },
    lb = {
      type = 'number',
      description = 'The blue component of the linear-space color.'
    },
    color = {
      type = 'table',
      description = 'A table containing the components of a linear-space color.'
    },
    x = {
      type = 'number',
      description = 'The color channel to convert.'
    }
  },
  returns = {
    gr = {
      type = 'number',
      description = 'The red component of the resulting gamma-space color.'
    },
    gg = {
      type = 'number',
      description = 'The green component of the resulting gamma-space color.'
    },
    gb = {
      type = 'number',
      description = 'The blue component of the resulting gamma-space color.'
    },
    y = {
      type = 'number',
      description = 'The converted color channel.'
    }
  },
  variants = {
    {
      arguments = { 'lr', 'lg', 'lb' },
      returns = { 'gr', 'gg', 'gb' }
    },
    {
      description = 'A table can also be used.',
      arguments = { 'color' },
      returns = { 'gr', 'gg', 'gb' }
    },
    {
      description = 'Convert a single color channel.',
      arguments = { 'x' },
      returns = { 'y' }
    }
  },
  related = {
    'lovr.math.gammaToLinear'
  }
}
