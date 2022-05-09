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

uniform sampler2D sol_texture;
uniform sampler2D fsa_texture;
uniform sampler2D reflection;
uniform int sol_time;
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec4 sol_vcolor;

vec3 keys[5] = vec3[](
 vec3(122.0,164.0,230.0)/255.0,
 vec3(88.0,128.0,200.0)/255.0,
 vec3(65.0,147.0,106.0)/255.0,
 vec3(65.0,164.0,114.0)/255.0,
 vec3(81.0,106.0,155.0)/255.0
);


const float threshold = 0.01;

void main() {
    vec4 tex_color = COMPAT_TEXTURE(sol_texture, sol_vtex_coord);
    bool should_texture = false;
    if(distance(tex_color.rgb,keys[1]) > threshold) {
      should_texture = true;
    }
    bool should_refl = false;
    for(int i = 0; i < keys.length(); i++) {
      if(distance(tex_color.rgb,keys[i]) < threshold) {
          should_refl = true; break;
      }
    }
    if(should_refl) {
      float t = float(sol_time)*0.005;
      vec2 offset = vec2(sin(t+gl_FragCoord.y*0.5),0/*cos(t*0.77+gl_FragCoord.y*0.4)*/)*0.002;
      vec4 refl = COMPAT_TEXTURE(reflection,sol_vtex_coord+offset);
      tex_color.rgb = mix(tex_color.rgb,refl.rgb,0.3);
    }
    if(should_texture) {
      vec4 fsa = COMPAT_TEXTURE(fsa_texture, sol_vtex_coord);
      tex_color.rgb *= fsa.rgb;
    }
    FragColor = tex_color;
}
