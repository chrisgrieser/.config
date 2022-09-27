-- This demo renders a scene into a cubemap, then displays the rendered screen reflected on a sphere surface within the screen.
--
-- Sample contributed by andi mcc with help from holo

-- First a simple scene, a checkerboard floor and some floating cubes
-- Want to see how the cubemap is done? Skip this whole section

local scene = {}

function scene.load()
	scene.floorSize = 6
	scene.cubeCount = 60
	scene.boundMin = lovr.math.newVec3(-10, -1, -10)
	scene.boundMax = lovr.math.newVec3(10,   9,  10)
	scene.speed = 1
	scene.rotateSpeed = 1
	scene.cubeSize = 0.2
	scene.cubes = {}

	scene.sphereCenter = lovr.math.newVec3(0, 1.5, -0.5)
	scene.sphereRad = 0.125

	for i=1,scene.cubeCount do
		scene.generate(i, true)
	end
end

local function randomQuaternion()
	-- Formula from http://planning.cs.uiuc.edu/node198.html
	local u,v,w = math.random(), math.random(), math.random()
	return lovr.math.newQuat( math.sqrt(1-u)*math.sin(2*v*math.pi),
		        math.sqrt(1-u)*math.cos(2*v*math.pi),
		        math.sqrt(u)*math.sin(2*w*math.pi),
		        math.sqrt(u)*math.cos(2*w*math.pi),
		        true ) -- Raw components
end

function scene.generate(i, randomZ) -- Generate each cube with random position and color and a random rotational velocity
	local cube = {}
	cube.at = lovr.math.newVec3()
	cube.at.x = scene.boundMin.x + math.random()*(scene.boundMax.x-scene.boundMin.x)
	cube.at.y = scene.boundMin.y + math.random()*(scene.boundMax.y-scene.boundMin.y)
	if randomZ then
		cube.at.z = scene.boundMin.z + math.random()*(scene.boundMax.z-scene.boundMin.z)
	else
		cube.at.z = scene.boundMin.z
	end
	cube.rotateBasis = randomQuaternion()
	cube.rotateTarget = lovr.math.newQuat(cube.rotateBasis:conjugate())
	cube.rotate = cube.rotateBasis
	cube.color = {math.random()*0.8, math.random()*0.8, math.random()*0.8}
	scene.cubes[i] = cube
end

function scene.update(dt) -- On each frame, move each cube and spin it a little
	for i,cube in ipairs(scene.cubes) do
		cube.at.z = cube.at.z + scene.speed*dt
		if cube.at.z > scene.boundMax.z then -- If cube left the scene bounds respawn it
			scene.generate(i)
		else
			local rotateAmount = (cube.at.z - scene.boundMin.z)/(scene.boundMax.z-scene.boundMin.z)
			cube.rotate = cube.rotateBasis:slerp( cube.rotateTarget, rotateAmount )
		end
	end
end

function scene.draw()
	lovr.graphics.setShader()

	-- First, draw a floor
	local floorRecenter = scene.floorSize/2 + 0.5
	for x=1,scene.floorSize do for y=1,scene.floorSize do
		if (x+y)%2==0 then
			lovr.graphics.setColor(0.25,0.25,0.25)
		else
			lovr.graphics.setColor(0.5,0.5,0.5)
		end
		lovr.graphics.plane('fill', x-floorRecenter,0,y-floorRecenter, 1,1, math.pi/2,1,0,0)
	end end

	-- Draw cubes
	for _,cube in ipairs(scene.cubes) do
		lovr.graphics.setColor(unpack(cube.color))
		lovr.graphics.cube('fill', cube.at.x, cube.at.y, cube.at.z, scene.cubeSize, cube.rotate:unpack())
	end
end

-- Now the cubemap stuff

local cubemap = {}

local unitX = lovr.math.newVec3(1,0,0)
local unitY = lovr.math.newVec3(0,1,0)
local unitZ = lovr.math.newVec3(0,0,1)

function cubemap.load()
	-- Create cubemap textures
	local cubemapWidth, cubemapHeight = 256, 256
	local skybox = lovr.graphics.newTexture(cubemapWidth, cubemapHeight, { format = "rg11b10f", stereo = false, type = "cube" })
	cubemap.faces = {}

	-- Precalculate cubemap View-Projection matrices
	local center = scene.sphereCenter
	local bias = unitZ * 0.001
	local up = -unitY
	cubemap.facePerspective = lovr.math.newMat4( lovr.math.mat4():perspective(90.0, 1, 0.1, 1000) )
	for i,matrix in ipairs{
		lovr.math.mat4():lookAt(center, center + unitX, up),
		lovr.math.mat4():lookAt(center, center - unitX, up),
		lovr.math.mat4():lookAt(center, center + unitY, up + bias),
		lovr.math.mat4():lookAt(center, center - unitY, up - bias),
		lovr.math.mat4():lookAt(center, center + unitZ, up),
		lovr.math.mat4():lookAt(center, center - unitZ, up)
	} do
		-- Each face will contain a matrix, and a preallocated canvas linked to the skybox cube texture
		local face = {}
		local canvas = lovr.graphics.newCanvas(skybox)
		canvas:setTexture(skybox, i)
		cubemap.faces[i] = lovr.graphics.newCanvas(skybox)
		cubemap.faces[i]:setTexture(skybox, i)

		cubemap.faces[i] = face
		face.canvas = canvas
		face.matrix = lovr.math.newMat4(matrix)
	end

	-- Create reflection shader
	cubemap.shader = lovr.graphics.newShader([[
		out vec3 viewAngle;
		out vec3 normal;
		vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
			mat4 view_from_local = lovrView * lovrModel; // Move to sphere center
			normal = normalize(view_from_local * vec4(lovrNormal, 0.0)).xyz; // What angle does our view reflect at?
			viewAngle = -(view_from_local * vertex).xyz; // Angle to query cube map from
			return projection * transform * vertex;      // Actual vertex to draw at
		}
	]], [[
		in vec3 viewAngle;
		in vec3 normal;
		uniform samplerCube cubemap;
		vec4 color(vec4 color, sampler2D image, vec2 uv) {
			vec3 n = normalize(normal);
			vec3 i = normalize(viewAngle);
			vec4 sphereColor = color*texture(cubemap, reflect(n, i));
			float ndi = dot(n, i) * 0.5 + 0.5; // Darken the sphere a little around the edges to give it apparent depth
			return vec4(sphereColor.rgb * ndi, 1.);
		}
	]])
	cubemap.shader:send("cubemap", skybox)
end

function cubemap.draw()
	local view = {lovr.graphics.getViewPose(1)} -- Manual "push" for view and projection
	local perspective = lovr.math.mat4()
	lovr.graphics.getProjection(1, perspective)

	-- On each frame, render the six faces of the cube map with the current item positions
	lovr.graphics.setProjection(1, cubemap.facePerspective)
	for i,face in ipairs(cubemap.faces) do
		face.canvas:renderTo(function()
			lovr.graphics.setViewPose(1,face.matrix,false)
			lovr.graphics.clear()
			scene.draw()
		end)
	end
	
	lovr.graphics.setProjection(1, perspective) -- Manual "pop" for view and projection
	lovr.graphics.setViewPose(1, unpack(view))

	-- Draw sphere textured with cube map
	lovr.graphics.setColor(1,0.6,0.6)
	lovr.graphics.setShader(cubemap.shader)
	lovr.graphics.sphere(scene.sphereCenter.x, scene.sphereCenter.y, scene.sphereCenter.z, scene.sphereRad)
end

-- Handle lovr

function lovr.load()
	lovr.graphics.setBackgroundColor(0.9,0.9,0.9)
	scene.load()
	cubemap.load()
end

function lovr.update(dt)
	scene.update(dt)
end

function lovr.draw()
	scene.draw()
	cubemap.draw()
end