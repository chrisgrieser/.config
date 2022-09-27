Callbacks and Modules
===

In the previous example we wrote some code in the `lovr.draw` function to draw text on the screen.
This is an example of a **callback** because we wrote a function and LÖVR "called back" into that
function later.  Defining a callback lets you specify how your project behaves when a specific event
occurs.

In the previous example we also used the `lovr.graphics.print` function to render text to the
screen.  This is an example of using the `lovr.graphics` **module**.  LÖVR has several modules and
each one contains functions related to a certain area of functionality.  For example, there's the
`lovr.graphics` module for rendering graphics, the `lovr.audio` module for playing sounds, and the
`lovr.headset` module for getting information about connected VR hardware.

We can define **callbacks** and call functions from **modules** to make things with LÖVR.

Callbacks
---

There are various callbacks that can be used for interesting things.  Three of the most used ones
are `lovr.load`, `lovr.update`, and `lovr.draw`.  A simple project skeleton might look like this:

```
function lovr.load()
  -- This is called once on load.
  --
  -- You can use it to load assets and set everything up.

  print('loaded!')
end

function lovr.update(dt)
  -- This is called continuously and is passed the "delta time" as dt, which
  -- is the number of seconds elapsed since the last update.
  --
  -- You can use it to simulate physics or update game logic.

  print('updating', dt)
end

function lovr.draw()
  -- This is called once every frame.
  --
  -- You can use it to render the scene.

  print('rendering')
end
```

By filling in the different callbacks you can start to define the behavior of an app.

To see a list of all the callbacks and read more about their specifics, check out the "Callbacks"
section on the sidebar.

Modules
---

You might be wondering what code to write in the different callbacks.  Inside callbacks you'll often
call into different modules to get LÖVR to do useful things.

A module is a plain Lua table that exposes a set of functions you can call.  Each module is
responsible for a specific area of functionality.  Some modules are relatively low level and, though
useful, they often aren't used in smaller projects.  The most commonly used modules are:

1. `lovr.graphics`
2. `lovr.headset`
3. `lovr.audio`
4. `lovr.physics`

Each module is described briefly below.

lovr.graphics
---

The graphics module is the most exciting module, and is also the largest.  Most functions in
`lovr.graphics` should be used in `lovr.draw`, since that's where rendering happens.

`lovr.graphics` has a set of handy **graphics primitives** for rendering basic shapes and text.
These can be used to quickly prototype a scene without needing to create or load assets.

There are lots of different rendering-related objects that can be created using `lovr.graphics`,
such as `Model`, `Texture`, `Font`, `Shader`, and more.  Every function to create a new
object is prefixed with `new`, so to create a 3D model object you can use `lovr.graphics.newModel`.

> Note: Creating graphics objects uses memory and can slow things down if done every frame.  For
> this reason, it's recommended to create objects only once in `lovr.load` before using them!

Another important component of `lovr.graphics` is **graphics state**.  The graphics renderer has a
number of state variables that can be changed, like the color of rendered objects, the font in use,
or the coordinate system.  These functions usually have prefixes of `get` or `set`, so to change the
active color you can use `lovr.graphics.setColor`.  It's important to keep in mind that this state
is **global**, so changing the color will affect all subsequent drawing operations until it's
changed again.

Finally, we'll talk about the coordinate system.  LÖVR uses a 3D coordinate system with values
specified in meters.  Negative z values are in front of the camera, positive y values are above the
ground, and negative x values are to the left.  By default, the coordinate system maps to the VR
play area, so the origin is on the ground in the middle of the play space.

You've already seen `lovr.graphics.print`, but here's another example:

```
function lovr.load()
  -- Load a 3D model
  model = lovr.graphics.newModel('monkey.obj')
end

function lovr.draw()
  -- Use a dark grey background
  lovr.graphics.setBackgroundColor(.2, .2, .2)

  -- Draw the model
  lovr.graphics.setColor(1.0, 1.0, 1.0)
  model:draw(-.5, 1, -3)

  -- Draw a red cube using the "cube" primitive
  lovr.graphics.setColor(1.0, 0, 0)
  lovr.graphics.cube('fill', .5, 1, -3, .5, lovr.timer.getTime())
end
```

lovr.headset
---

The headset module lets you interact with VR hardware.  You can get pose information for the HMD and
controllers, and also query the input state of controllers to see if buttons are pressed.  You can
also retrieve information about the configured play area so you know how much available space there
is to place objects.

Pose information consists of the position and orientation of a tracked device, which is useful
because it lets you know where the device is and which way it's facing.  To get the position of the
HMD, you can call `lovr.headset.getPosition` which returns 3 numbers corresponding to an xyz
position in 3D space.  You can also call `lovr.headset.getOrientation` which returns four numbers
representing a rotation in angle/axis format.

You can also pass the name of a hand to these functions to get the pose of a hand: `hand/left` or
`hand/right`.  The `lovr.headset.isDown(hand, button)` and `lovr.headset.getAxis(hand, axis)`
functions can be used to figure out the state of buttons and other controls on the controllers.

Here's a simple example that draws a sphere in the "opposite" position of the headset:

```
function lovr.draw()
  local x, y, z = lovr.headset.getPosition()
  lovr.graphics.sphere(-x, y, -z, .1)
end
```

lovr.audio
---

Sound can be played with `lovr.audio`.  Audio is spatialized, so sounds can have positions and
directions, which are used to make things sound realistic as the headset moves and rotates.

Each instance of a sound is called a `Source`.  To create a sources, use `lovr.audio.newSource` and
pass it an ogg file.  You can then call `play` on the source to play it.

```
function lovr.load()
  ambience = lovr.audio.newSource('background.ogg')
  ambience:setLooping(true)
  ambience:play()
end
```

See the `Source` page for more information.

lovr.physics
---

Adding a physics simulation to a scene can make it feel more realistic and immersive.  The
`lovr.physics` module can be used to set up a physics simulation.

> Note: Physics engines can be tricky to set up.  There are lots of knobs to turn and it may take
> some tweaking to get things working well.

The first step to creating a simulation is to create a `World` using `lovr.physics.newWorld`.  After
a world is created you can add `Collider`s to it, using functions like `World:newBoxCollider` or
`World:newCylinderCollider`.  Each collider represents a single entity in the simulation and can have
forces applied it.  The world should be updated in `lovr.update` using the `dt` value.

Here's an example that makes a tower of boxes that you can knock down with controllers:

```
function lovr.load()
  world = lovr.physics.newWorld()

  -- Create the ground
  world:newBoxCollider(0, 0, 0, 5, .01, 5):setKinematic(true)

  -- Create boxes!
  boxes = {}
  for x = -1, 1, .25 do
    for y = .125, 2, .25 do
      local box = world:newBoxCollider(x, y, -1, .25)
      table.insert(boxes, box)
    end
  end

  -- Each controller is going to have a collider attached to it
  controllerBoxes = {}
end

function lovr.update(dt)
  -- Synchronize controllerBoxes with the active controllers
  for i, hand in ipairs(lovr.headset.getHands()) do
    if not controllerBoxes[i] then
      controllerBoxes[i] = world:newBoxCollider(0, 0, 0, .25)
      controllerBoxes[i]:setKinematic(true)
    end
    controllerBoxes[i]:setPosition(lovr.headset.getPosition(hand))
    controllerBoxes[i]:setOrientation(lovr.headset.getOrientation(hand))
  end

  -- Update the physics simulation
  world:update(dt)
end

-- A helper function for drawing boxes
function drawBox(box)
  local x, y, z = box:getPosition()
  lovr.graphics.cube('line', x, y, z, .25, box:getOrientation())
end

function lovr.draw()
  lovr.graphics.setColor(1.0, 0, 0)
  for i, box in ipairs(boxes) do
    drawBox(box)
  end

  lovr.graphics.setColor(0, 0, 1.0)
  for i, box in ipairs(controllerBoxes) do
    drawBox(box)
  end
end
```

Next Steps
---

To explore a module or callback in more detail, see the reference page for the `lovr` global.

There are also a number of <a data-key="Libraries">Libraries</a> you can use that may come in handy.
