-- This demo renders four examples of mesh drawing:
-- A plain mesh (one triangle, white)
-- A mesh with a vertex map, in other words indexed triangles (a cube, magenta)
-- An instanced mesh with its size controlled by gl_InstanceID and an equation (512 cubes animated, cyan)
-- An instanced mesh with its size controlled by an attached attribute (512 cubes with random sizes, yellow)
--
-- Sample contributed by andi mcc

local fragmentShader = require("shader")

local mesh1, mesh2, mesh4
local mesh4Instance
local mesh1Program, mesh3Program, mesh4Program
local gridSize = 8
local gridSizeCubed = gridSize*gridSize*gridSize

-- This reproduces a simple lighting shader, but in the vertex shader
-- the mesh coordinate is run through a customized function first.
-- Call this function with a string containing a glsl function preTransform()
-- which maps world space coordinates to world space coordinates to construct a shader.
local function makeShader(prefix)
  return lovr.graphics.newShader(prefix .. [[
out vec3 lightDirection;
out vec3 normalDirection;
out vec3 vertexPosition;

vec3 lightPosition = vec3(10., 10., 3.);

vec4 position(mat4 projection, mat4 transform, vec4 _vertex) {
  vec4 vertex = preTransform(_vertex);

  vec4 vVertex = transform * vertex;
  vec4 vLight = lovrView * vec4(lightPosition, 1.);

  lightDirection = normalize(vec3(vLight - vVertex));
  normalDirection = normalize(lovrNormalMatrix * lovrNormal);
  vertexPosition = vVertex.xyz;

  return projection * transform * vertex;
}
]], fragmentShader)
end

local animate = 0

function lovr.load()
  lovr.graphics.setCullingEnabled(true)

  -- This "standard" program is the same as the lighting shader from the other examples-- it does nothing.
  mesh1Program = makeShader("vec4 preTransform(vec4 v) { return v; }")

  -- This mesh is a single triangle
  mesh1 = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 }, { 'lovrNormal', 'float', 3 }}, 3, 'triangles')
  mesh1:setVertices({{0,0,0, 0,0,1}, {1,0,0, 0,0,1}, {0,1,0, 0,0,1}})

  -- This mesh is a cube
  mesh2 = lovr.graphics.newMesh({{ 'lovrPosition', 'float', 3 }, { 'lovrNormal', 'float', 3 }}, 24, 'triangles')
  local mesh2Vertices = {
    {0,0,0, 0,0,-1}, -- Face front
    {0,1,0, 0,0,-1},
    {1,1,0, 0,0,-1},
    {1,0,0, 0,0,-1},

    {1,1,0, 0,1,0}, -- Face top
    {0,1,0, 0,1,0},
    {0,1,1, 0,1,0},
    {1,1,1, 0,1,0},

    {1,0,0, 1,0,0}, -- Face right
    {1,1,0, 1,0,0},
    {1,1,1, 1,0,0},
    {1,0,1, 1,0,0},

    {0,0,0, -1,0,0}, -- Face left
    {0,0,1, -1,0,0},
    {0,1,1, -1,0,0},
    {0,1,0, -1,0,0},

    {1,1,1, 0,0,1}, -- Face back
    {0,1,1, 0,0,1},
    {0,0,1, 0,0,1},
    {1,0,1, 0,0,1},

    {0,0,0, 0,-1,0}, -- Face bottom
    {1,0,0, 0,-1,0},
    {1,0,1, 0,-1,0},
    {0,0,1, 0,-1,0}
  }

  -- The cube specified above covers the space 0..1, so it's centered at (0.5, 0.5, 0.5). That's not right.
  -- Let's edit the first three coordinates of each vertex to center it at (0,0,0):
  for _, v in ipairs(mesh2Vertices) do
    for i=1,3 do
      v[i] = v[i] - 0.5
    end
  end

  mesh2:setVertices(mesh2Vertices)

  -- Indices to draw the faces of the cube out of triangles
  local mesh2Indexes = {
    1,  2,  3,  1,  3,  4,  -- Face front
    5,  6,  7,  5,  7,  8,  -- Face top
    9,  10,  11, 9,  11, 12, -- Face right
    13, 14, 15, 13, 15, 16, -- Face left
    17, 18, 19, 17, 19, 20, -- Face back
    21, 22, 23, 21, 23, 24, -- Face bottom
  }

  mesh2:setVertexMap(mesh2Indexes)

  -- This program draws many "instances" of a single model (in this example, a cube, but it could be anything)
  -- but uses the instance ID to recenter the model so that the various copies pack the volume of a cube.
  -- The model is resized according to a uniform and a little equation to make them wave nicely.
  mesh3Program = makeShader([[
  uniform int gridSize;
  uniform float animate;
  vec4 preTransform(vec4 v) {
    int instance = lovrInstanceID;
    int x = instance % gridSize;
    int y = (instance / gridSize) % gridSize;
    int z = (instance / gridSize) / gridSize;
    float cubeSize = (sin(float(x + y + z) + animate) + 1.) / 2.;
    return v * vec4(cubeSize,cubeSize,cubeSize,1) + vec4(x,y,z,0.) - vec4(gridSize, gridSize, gridSize, 0.)/2.;
  }
  ]])
  mesh3Program:send("gridSize", gridSize)

  -- This is exactly like the last program-- many instances of one model, packed into a cube volume.
  -- The difference is instead of the size being set by a single uniform, we'll pass in a list of sizes.
  -- We only have to pass in the cube mesh once, and it matches a copy of the cube for each size in the list.
  mesh4Program = makeShader([[
  uniform int gridSize;
  in float cubeSize;
  vec4 preTransform(vec4 v) {
    int instance = lovrInstanceID;
    int x = instance % gridSize;
    int y = (instance / gridSize) % gridSize;
    int z = (instance / gridSize) / gridSize;
    return v * vec4(cubeSize,cubeSize,cubeSize,1.) + vec4(x,y,z,0.) - vec4(gridSize, gridSize, gridSize, 0.)/2.;
  }
  ]])
  mesh4Program:send("gridSize", gridSize)

  -- Here we make an alternate version of mesh 2 (the cube) with the size list attached.
  mesh4 = lovr.graphics.newMesh({}, 24, 'triangles')
  mesh4Instance = lovr.graphics.newMesh({{'cubeSize', 'float', 1}}, gridSizeCubed, 'points')
  local mesh4Vertices = {}
  for i=1,gridSizeCubed do                       -- Hmm, what sizes should we use?
    table.insert(mesh4Vertices, {math.random()}) -- Let's just make them random.
  end
  mesh4Instance:setVertices(mesh4Vertices)
  mesh4:setVertexMap(mesh2Indexes)
  mesh4:attachAttributes(mesh2)
  mesh4:attachAttributes(mesh4Instance, 1)
end

function lovr.update(dt)
  animate = animate + dt/math.pi*2
end

function lovr.draw(eye)
  lovr.graphics.setShader(mesh1Program)

  lovr.graphics.push() -- White triangle
  lovr.graphics.setColor(1,1,1)
  lovr.graphics.translate(0, 0, -2)
  mesh1:draw(0,0,0)
  lovr.graphics.pop()

  lovr.graphics.push() -- Magenta cube
  lovr.graphics.setColor(1,0,1)
  lovr.graphics.rotate(1 * math.pi/2, 0, 1, 0)
  lovr.graphics.translate(0, 0, -2)
  mesh2:draw(0,0,0)
  lovr.graphics.pop()

  lovr.graphics.setShader(mesh3Program) -- Cyan cubes with size animated by uniform
  lovr.graphics.setColor(0,1,1)
  lovr.graphics.push()
  lovr.graphics.rotate(2 * math.pi/2, 0, 1, 0)
  lovr.graphics.translate(0, 0, -2)
  lovr.graphics.scale(1/gridSize)
  mesh3Program:send("animate", animate)
  mesh2:draw(lovr.math.mat4(), gridSizeCubed)
  lovr.graphics.pop()

  lovr.graphics.setShader(mesh4Program) -- Yellow cubes with size specified by mesh4
  lovr.graphics.setColor(1,1,0)
  lovr.graphics.push()
  lovr.graphics.rotate(3 * math.pi/2, 0, 1, 0)
  lovr.graphics.translate(0, 0, -2)
  lovr.graphics.scale(1/gridSize)
  mesh4:draw(lovr.math.mat4(), gridSizeCubed)
  lovr.graphics.pop()

  lovr.graphics.setColor(1,1,1)
  lovr.graphics.setShader()
end
