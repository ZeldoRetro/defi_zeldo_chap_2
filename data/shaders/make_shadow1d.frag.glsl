#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
precision mediump float;
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif
#define PI 3.14

//inputs from vertex shader
COMPAT_VARYING vec2 sol_vtex_coord;

//uniform values
uniform sampler2D sol_texture;
uniform vec2 resolution;

//alpha threshold for our occlusion map
const float THRESHOLD = 0.75;

void main(void) {
  float distance = 1.0;
  vec4 last = vec4(0.0,0.0,0.0,1.0);
  float lastd = distance;
  bool once_in_air = false;
  for (float y=0.0; y<resolution.y; y+=1.0) {
      //rectangular to polar filter
      vec2 norm = vec2(sol_vtex_coord.s, y/resolution.y) * 2.0 - 1.0;
      float theta = PI*1.5 + norm.x * PI; 
      float r = (1.0 + norm.y) * 0.5;

      //coord which we will sample from occlude map
      vec2 coord = vec2(-r * sin(theta), -r * cos(theta))/2.0 + 0.5;

      //sample the occlusion map
      vec4 data = COMPAT_TEXTURE(sol_texture, coord);

      //the current distance is how far from the top we've come
      float dst = y/resolution.y;

      //if we've hit an opaque fragment (occluder), then get new distance
      //if the new distance is below the current, then we'll use that for our ray
      float caster = data.a;
      
      if (last.a > THRESHOLD && caster < last.a && once_in_air) {
        distance = min(distance, lastd);
        //NOTE: we could probably use "break" or "return" here
        break;
      }
      if(data != last || last.a < THRESHOLD) {
        once_in_air = true;
      }
      last = data;
      lastd = dst;
      
    } 
    FragColor = vec4(vec3(distance), 1.0);
}
