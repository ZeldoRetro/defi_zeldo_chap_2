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


//inputs from vertex shader
COMPAT_VARYING vec2 sol_vtex_coord;
COMPAT_VARYING vec2 plain_tex_coord;

//uniform values
uniform sampler2D sol_texture;
uniform sampler2D plasma;
uniform int sol_time;

void main(void) {
    float time = float(sol_time)*0.01;
    float mask = COMPAT_TEXTURE(sol_texture,sol_vtex_coord).r;
    vec4 pls = vec4(sin(time+gl_FragCoord.y*0.5),0.3*cos(time*0.5+1.0),0.0,1.0);
    pls = (pls+vec4(1))*0.5;
    FragColor = pls*mask;
    //color = vec4(1,0,0,1);
}
