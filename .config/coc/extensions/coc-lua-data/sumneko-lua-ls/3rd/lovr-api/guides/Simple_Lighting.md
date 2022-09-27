Simple Lighting Tutorial
===

This guide assumes basic knowledge of LÖVR project structure and Lua in general. If you haven't already, you should at least do the [Getting Started](https://lovr.org/docs/Getting_Started) tutorial first!

Intro
---

Lighting in LÖVR is tricky for the uninitiated. There are no lighting prefabs or constructors -- you must do it all by hand. Luckily, it's not that hard! 

We've been spoiled by applications that create "lights" for us, so we think of them as objects that cast light within the rendering space. This is not how lighting is done for most video games - casting light itself in a realistic way is [extremely GPU-consuming](https://store.steampowered.com/agecheck/app/1089130/).

What many 3D games do is they will process the color of each pixel on the screen (called a 'fragment' in shader language) based on the angle, distance, and color of the 'imaginary' lights hitting it.

This is done in three phases, in a very common lighting model called the Phong model.

(This tutorial was adapted from the very well-written LearnOpenGL tutorial in C++, [found here](https://learnopengl.com/Lighting/Basic-Lighting)).

Our First Shaders
---

Assuming you already have a project set up and are loading and displaying a model, let's try initializing a custom shader first. To do that, we write a slightly modified OpenGL .vs (vertex shader) which we store as a multi-line string in Lua:

    customVertex = [[
        vec4 position(mat4 projection, mat4 transform, vec4 vertex)
        {
            return projection * transform * vertex;
        }
    ]]

Note for now this is just the default LÖVR vertex shader as listed in the [Shader page of the manual](https://lovr.org/docs/Shader).

Now, we define a new shader with customVertex:

    shader = lovr.graphics.newShader(customVertex, nil, {})

For the newShader method, passing nil as an argument will use the default fragment shader. Now, to enable the shader, we add to lovr.draw():

    lovr.graphics.setShader(shader)

(You may have to setShader() to reset the shader at the end of draw() if you have any issues).
If you run this as-is, it should perform exactly as if you had the default shader. Let's do the same thing for the fragment shader:

    customFragment = [[
        vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
        {
            return graphicsColor * lovrDiffuseColor * vertexColor * texture(image, uv);
            }
    ]]

Changing nil in the newShader line to customFragment should again run with no issues.

Now let's get to ambient lighting!

Phase 1 - Ambience 
---

Step one of the Phong model is ambient lighting. Light bounces around everywhere, especially in the daytime, and even rooms without lights can be well-lit. You will likely change your ambient level frequently during the game, so being familiar with its affect on your scene is important.

The default LÖVR shader is "unlit", which means effectively your ambient lighting is at 100% all the time - all angles of all polygons are always fully bright. This is fine for certain things, but for rendering a 3d model in a virtual space, shading is pretty important. For our purposes, we are implementing ambient lighting by "turning down" this unlit effect to about 20% - a good value for rooms in the daytime, but you may find 10% or 30% more to your liking.

Here's the new fragment shader:

    customFragment = [[
        uniform vec4 ambience;
        vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
        {
            //object color
            vec4 baseColor = graphicsColor * texture(image, uv);
            return baseColor * ambience;
        }
    ]]
    shader:send('ambience', { 0.2, 0.2, 0.2, 1.0 })

We changed a bit here. First, we added a new 'uniform' variable to represent the ambient light color. Uniform is a keyword that allows us to expose values through the LÖVR / Lua interface, so we can change them freely. We do this with the shader's :send method. Assigning a value to the uniform variable in this way is 'safe' programming - if you try to assign a value to a uniform variable in it's declaration on Android, the game will crash and complain. The color is set to a 20% grey, but you can pick any color. The values correspond to R, G, B, A - though for this case you generally want the alpha value to be 1.0, otherwise anything drawn with this shader will be rendered as transparent.

Second, we are changing a lot about the value being returned.

The original code has graphicsColor (the value of lovr.graphics.setColor()) being multiplied by lovrDiffuseColor - this is a value of { 1.0, 1.0, 1.0, 1.0 }, but for simplicities' sake, let's just not use this value (it's stored in a hidden shader header) and use our own!

Also, we don't need the vertexColor. This is another value which defaults to 1 that is separate from our draw color, and the texture color, and our new ambience color.

This should be a wee bit faster than it was, one would hope, by omitting a few unneeded variables. If you run your game, everything should look -considerably darker- than before. This is good! Now we layer on the diffuse lighting!

Phase 2 - Diffusion
---
A group of vertices is, of course, a polygon. A ray emitting perpendicular from this polygon is the 'normal'. Depending on the angle of the position of the light versus the normals of your in-game models, the polygons are applied a percentage of the light cast. This makes sense and can be easily proven in the real world - the side of a box facing a light is brighter than the sides, which are brighter than the side facing away, etc.

Diffuse lighting simulates some of the bounce effect that ambient lighting does, with added bias on polygons perpendicular to the light source. 

To do this properly, we need to get the position of and normal of the vertex from within the vertex shader -- this means taking a 3d vector that comes "out of" the polygon -- and passing it to the fragment (pixel or color) shader so we know how "bright" to render that spot on the screen. 

The math for all of this is much better explained and proofed elsewhere, including the LearnOpenGL link above, but rest assured it has been done and triple checked a million times by a million people. What we need to know is how to do it in LÖVR!

Luckily, LÖVR loves you, and makes this very easy. Here's the new vertex shader:

    defaultVertex = [[
        out vec3 FragmentPos;
        out vec3 Normal;

        vec4 position(mat4 projection, mat4 transform, vec4 vertex) 
        { 
            Normal = lovrNormalMatrix * lovrNormal;
            FragmentPos = vec3(lovrModel * vertex);
            
            return projection * transform * vertex; 
        }
    ]]

'out' is a keyword that simply passes the variable along to the fragment shader when the vertex shader is done. Doing this allows us to use the fragment position in world space and the vertex's normal to calculate our lighting changes. 

>Special note: Casting and converting vec3 and vec4 can be annoying. Luckily, GLSL makes this easy by allowing a special .xyz method on vec4 variables that will do this for us, e.g. we could have done: FragmentPos = (lovrModel * vertex).xyz instead and it would perform the same.

In LÖVR, lovrNormal is defined as the vertex's normal, if one exists. Easy - already calculated for us! The reason why we multiply it by the lovrNormalMatrix is so the lighting is applied to the final transform value - i.e. the rotation and position as well.

FragmentPos is less self-explanatory, but what we need to know is that this represents the xyz component of the current vertex of the currently being rendered model (of type lovrModel). In other words, a single visible point on the model. 

Now the important part, using that data on our fragment shader:

    defaultFragment = [[
        uniform vec4 ambience;
        
        uniform vec4 liteColor;
        uniform vec3 lightPos;

        in vec3 Normal;
        in vec3 FragmentPos;
        
        vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
        {    
            //diffuse
            vec3 norm = normalize(Normal);
            vec3 lightDir = normalize(lightPos - FragmentPos);
            float diff = max(dot(norm, lightDir), 0.0);
            vec4 diffuse = diff * liteColor;
                            
            vec4 baseColor = graphicsColor * texture(image, uv);            
            return baseColor * (ambience + diffuse);
        }
    ]]
    shader:send('liteColor', {1.0, 1.0, 1.0, 1.0})
    shader:send('lightPos', {2.0, 5.0, 0.0})

The math and reasoning for this is explained in the LearnOpenGL tutorial, so here's the important bits for LÖVR:

- liteColor is a new uniform vec4, of values RGBA, that represents the individual light's emissive color
- lightPos is the position in world space the individual light emits light from 
- 'in' is used here to indicate the variables we want from the vertex shader
- normalize() is an OpenGL function to make operations like this easier
- We are now returning the baseColor of the fragment times ambience PLUS diffuse - be sure these are added, not multiplied together

If you compile and run now, you should notice a bright light illuminating your scene. Experiment with variables and using the 'send' method (shader:send('liteColor', <new color table>) or shader:send('lightPos', <new position>)) in your draw() loops.

Almost there!!

Phase 3 - Specularity
---
Specular lighting does the least changes to individual pixels, but amounts to the most detail. For this implementation, we will be using view space, i.e. x y z of 0, 0, 0, for ease of calculation. If you read the accompanying tutorial, you know that performing these calculations in world space is more realistic. I'm sure you can think of games that use view space calculations -- ones in which the specular light reflections sort of followed your eyes as you moved. Now you know why!

We don't need to make any changes to the vertex shader, so here's the final fragment shader:

    defaultFragment = [[
        uniform vec4 ambience;

        uniform vec4 liteColor;
        uniform vec3 lightPos;

        in vec3 Normal;
        in vec3 FragmentPos;

        uniform vec3 viewPos;
        uniform float specularStrength;
        uniform int metallic;
            
        vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
        {    
            //diffuse
            vec3 norm = normalize(Normal);
            vec3 lightDir = normalize(lightPos - FragmentPos);
            float diff = max(dot(norm, lightDir), 0.0);
            vec4 diffuse = diff * liteColor;
                
            //specular
            vec3 viewDir = normalize(viewPos - FragmentPos);
            vec3 reflectDir = reflect(-lightDir, norm);
            float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
            vec4 specular = specularStrength * spec * liteColor;
                
            vec4 baseColor = graphicsColor * texture(image, uv);            
            return baseColor * (ambience + diffuse + specular);
        }
    ]]
    shader:send('liteColor', {1.0, 1.0, 1.0, 1.0})
    shader:send('lightPos', {2.0, 5.0, 0.0})
    shader:send('ambience', {0.1, 0.1, 0.1, 1.0})
    shader:send('specularStrength', 0.5)
    shader:send('metallic', 32.0)
    shader:send('viewPos', {0.0, 0.0, 0.0})

viewPos at (0, 0, 0) is fine for a static camera, but we're doing VR, after all! If you have a headset connected, feel free to modify lovr.update:

    function lovr.update(dT)
        if lovr.headset then 
            hx, hy, hz = lovr.headset.getPosition()
            shader:send('viewPos', { hx, hy, hz } )
        end
    end

>Special Note 2: The viewing position (not as much angle) is very important for the effectiveness of specular light. Moving the camera in the desktop mirror of lovr does not change the view position, so you might get lighting artifacts if you move the camera without updating the view position. Try this with a headset on!

specularStrength is the 'harshness' of the light. This generally amounts to how sharp or bright the light's reflection can look.

metallic is the metallic exponent as shown in the LearnOpenGL tutorial. This value should probably range from 4-256, but 32 is fine for most things. 

The rest of the math hasn't changed - we're just adding the specular value to the final fragment color. 

And that's it! With any luck, you'll have a properly-lit model like so (lightPos adjusted to 2.0, 5.0, 0.0):

![Phong Tutorial Image](https://lovr.org/static/img/phongpic.png)

There's lots of playing around you can do - experiment with multiple lights, new shaders that are variants on the theme, and explore GLSL. 

>Special Note 3: For factorization purposes, you can keep the vertex and fragment shader code in seperate files (default extension for them is .vs and .fs). You can use the lovr.filesystem.read() command to load them in as strings just like above. The advantage of this is using syntax highlighting or linting when coding your shaders i.e. in VS Code.

>Final Note: If you are having issues with some faces on your models not being lit properly, there are a few things to check on your model. 
>First, make sure it is built with a uniform scale. This can easily be done in Blender by selecting a properly scaled piece, then A to select the entire model, then Cmd+A (Apply) -> Scale. There is also the uniformScale shader flag, which gives a small speed boost - you should be developing everything in uniform scale in VR anyway!
>Second, all model faces need to be facing the correct way to generate their normal properly for lighting. If you notice some parts of your model are shading in the opposite direction, you can flip the face direction in Blender by selecting it all in edit mode, then Opt+N > Recalculate Normals or Flip Normals. 
>These two tips should fix 90% of any issues!

[Complete source code for this tutorial can be found here.](https://barelyconsciousgames.com/lovr-phong.zip)

This should work on your Quest, Go, or GearVR as well if you follow the instructions on the LÖVR website for [deploying to Android](https://lovr.org/docs/Getting_Started_(Quest)). A moving, unlit sphere was added in the example to represent the light source to better visualize it.

Have fun with LÖVR!
