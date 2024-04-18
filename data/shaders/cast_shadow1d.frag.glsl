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
#define PI 3.1415

//inputs from vertex shader
COMPAT_VARYING vec2 sol_vtex_coord;

//uniform values
uniform sampler2D sol_texture;
uniform vec2 resolution;
uniform vec3 lcolor;
uniform int sol_time;
uniform vec2 dir;
uniform float aperture;
uniform float halo;
uniform float cut;
uniform bool oscillate;

//sample from the 1D distance map
float tex(vec2 coord, float r) {
	return step(r, COMPAT_TEXTURE(sol_texture, coord).r);
}

void main(void) {
	//rectangular to polar
	vec2 norm = sol_vtex_coord.st * 2.0 - 1.0;
	float theta = atan(-norm.y, norm.x);
	float r = length(norm);	
	float coord = (theta + PI) / (2.0*PI);
	
	//the tex coord to sample our 1D lookup texture	
	//always 0.0 on y axis
	vec2 tc = vec2(coord, 0.0);
	
	//the center tex coord, which gives us hard shadows
	float center = tex(tc, r);        
	
	//we multiply the blur amount by our distance from center
	//this leads to more blurriness as the shadow "fades away"
	float blur = /*0.001 +*/ (0.2/resolution.x)  * smoothstep(0., 1., r) * halo * 10.0; 
	
	//now we use a simple gaussian blur
	float sum = 0.2;
	
	sum += tex(vec2(tc.x - 4.0*blur, tc.y), r) * 0.05;
	sum += tex(vec2(tc.x - 3.0*blur, tc.y), r) * 0.09;
	sum += tex(vec2(tc.x - 2.0*blur, tc.y), r) * 0.12;
	sum += tex(vec2(tc.x - 1.0*blur, tc.y), r) * 0.15;
	sum += center * 0.16;
	sum += tex(vec2(tc.x + 1.0*blur, tc.y), r) * 0.15;
	sum += tex(vec2(tc.x + 2.0*blur, tc.y), r) * 0.12;
	sum += tex(vec2(tc.x + 3.0*blur, tc.y), r) * 0.09;
	sum += tex(vec2(tc.x + 4.0*blur, tc.y), r) * 0.05;
	
	//sum of 1.0 -> in light, 0.0 -> in shadow
 	
 	//multiply the summed amount by our distance, which gives us a radial falloff
 	//then multiply by vertex (light) color
  float dr = oscillate ? 0.035*(1.0+sin(float(sol_time+600)*0.0062831)) : 0.0;
  
 	FragColor = vec4(vec3(sum * smoothstep(1.0, 0.0, r-dr))*lcolor,1);
  
  float cone = smoothstep(aperture-halo,aperture+halo,dot(dir,normalize(norm)));
  float b = step(cut,r);
  FragColor.rgb *= cone*b;
  //color = vec4(1,0,0,1);
}
