return {
  summary = 'Compute mass properties for the Collider.',
  description = 'Computes mass properties for the Collider.',
  arguments = {},
  returns = {
    {
      name = 'cx',
      type = 'number',
      description = 'The x position of the center of mass.'
    },
    {
      name = 'cy',
      type = 'number',
      description = 'The y position of the center of mass.'
    },
    {
      name = 'cz',
      type = 'number',
      description = 'The z position of the center of mass.'
    },
    {
      name = 'mass',
      type = 'number',
      description = 'The computed mass of the Collider.'
    },
    {
      name = 'inertia',
      type = 'table',
      description = [[
        A table containing 6 values of the rotational inertia tensor matrix.  The table contains the
        3 diagonal elements of the matrix (upper left to bottom right), followed by the 3 elements
        of the upper right portion of the 3x3 matrix.
      ]]
    }
  },
  related = {
    'Collider:getMass',
    'Collider:setMass',
    'Shape:getMass'
  }
}
