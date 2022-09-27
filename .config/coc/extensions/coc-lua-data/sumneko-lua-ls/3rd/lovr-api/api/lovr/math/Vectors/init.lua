return {
  summary = 'What is your vector victor.',
  description = [[
    LÖVR has math objects for vectors, matrices, and quaternions, collectively called "vector
    objects".  Vectors are useful because they can represent a multidimensional quantity (like a 3D
    position) using just a single value.
  ]],
  constructors = {
    'lovr.math.vec2',
    'lovr.math.vec3',
    'lovr.math.vec4',
    'lovr.math.quat',
    'lovr.math.mat4',
    'lovr.math.newVec2',
    'lovr.math.newVec3',
    'lovr.math.newVec4',
    'lovr.math.newQuat',
    'lovr.math.newMat4'
  },
  notes = [[
    Most LÖVR functions that accept positions, orientations, transforms, velocities, etc. also accept
    vector objects, so they can be used interchangeably with numbers:

        function lovr.draw()
          -- position and size are vec3's, rotation is a quat
          lovr.graphics.box('fill', position, size, rotation)
        end

    ### Temporary vs. Permanent

    Vectors can be created in two different ways: **permanent** and **temporary**.

    **Permanent** vectors behave like normal LÖVR objects.  They are individual objects that are garbage
    collected when no longer needed.  They're created using the usual `lovr.math.new<Type>` syntax:

        self.position = lovr.math.newVec3(x, y, z)

    **Temporary** vectors are created from a shared pool of vector objects.  This makes them faster
    because they use temporary memory and do not need to be garbage collected.  To make a temporary
    vector, leave off the `new` prefix:

        local position = lovr.math.vec3(x, y, z)

    As a further shorthand, these vector constructors are placed on the global scope.  If you prefer to
    keep the global scope clean, this can be configured using the `t.math.globals` flag in `lovr.conf`.

        local position = vec3(x1, y1, z1) + vec3(x2, y2, z2)

    Temporary vectors, with all their speed, come with an important restriction: they can only be used
    during the frame in which they were created.  Saving them into variables and using them later on
    will throw an error:

        local position = vec3(1, 2, 3)

        function lovr.update(dt)
          -- Reusing a temporary vector across frames will error:
          position:add(vec3(dt))
        end

    It's possible to overflow the temporary vector pool.  If that happens, `lovr.math.drain` can be used
    to periodically drain the pool, invalidating any existing temporary vectors.

    ### Metamethods

    Vectors have metamethods, allowing them to be used using the normal math operators like `+`, `-`,
    `*`, `/`, etc.

        print(vec3(2, 4, 6) * .5 + vec3(10, 20, 30))

    These metamethods will create new temporary vectors.

    ### Components and Swizzles

    The raw components of a vector can be accessed like normal fields:

        print(vec3(1, 2, 3).z) --> 3
        print(mat4()[16]) --> 1

    Also, multiple fields can be accessed and combined into a new (temporary) vector, called swizzling:

        local position = vec3(10, 5, 1)
        print(position.xy) --> vec2(10, 5)
        print(position.xyy) --> vec3(10, 5, 5)
        print(position.zyxz) --> vec4(1, 5, 10, 1)

    The following fields are supported for vectors:

    - `x`, `y`, `z`, `w`
    - `r`, `g`, `b`, `a`
    - `s`, `t`, `p`, `q`

    Quaternions support `x`, `y`, `z`, and `w`.

    Matrices use numbers for accessing individual components in "column-major" order.

    All fields can also be assigned to.

        -- Swap the components of a 2D vector
        v.xy = v.yx

    The `unpack` function can be used (on any vector type) to access all of the individual components of
    a vector object.  For quaternions you can choose whether you want to unpack the angle/axis
    representation or the raw quaternion components.  Similarly, matrices support raw unpacking as well
    as decomposition into translation/scale/rotation values.
  ]]
}
