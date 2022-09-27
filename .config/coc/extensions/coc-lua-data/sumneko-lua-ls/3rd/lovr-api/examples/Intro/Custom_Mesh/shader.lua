-- Copy of fragment shader from Physics example
return [[
in vec3 lightDirection;
in vec3 normalDirection;
in vec3 vertexPosition;

vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
  vec3 cAmbient = vec3(.25);
  vec3 cDiffuse = vec3(1.);
  vec3 cSpecular = vec3(.35);

  float diffuse = max(dot(normalDirection, lightDirection), 0.);
  float specular = 0.;

  if (diffuse > 0.) {
    vec3 r = reflect(lightDirection, normalDirection);
    vec3 viewDirection = normalize(-vertexPosition);

    float specularAngle = max(dot(r, viewDirection), 0.);
    specular = pow(specularAngle, 5.);
  }

  vec3 cFinal = pow(clamp(vec3(diffuse) * cDiffuse + vec3(specular) * cSpecular, cAmbient, vec3(1.)), vec3(.4545));
  return vec4(cFinal, 1.) * graphicsColor * texture(image, uv);
}
]]
