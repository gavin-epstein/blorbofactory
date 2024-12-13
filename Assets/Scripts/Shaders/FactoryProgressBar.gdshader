shader_type spatial;
uniform float progress = 0.9;
uniform vec3 color = vec3(1,0,0);
varying float angle;
void vertex() {
	// objCenter_ws =  //model to world
	// Called for every vertex the material is visible on.
	vec4 objCenter_os =  vec4(0,0,0,1.0);
	//vec4 vert_os =  VERTEX;
	vec4 fromcenter_os =  vec4(0,0,0,1.0) - vec4(VERTEX,1); 
	angle =  atan(fromcenter_os.x,fromcenter_os.z);
	
}

void fragment() {
	
	//vec2 fromcenter = vert_ss.xy - objCenter_ss.xy; 
	//float angle = atan(fromcenter.y/fromcenter.x)/(2.0*PI);
	ALBEDO = color;
	//ALBEDO = vec3(angle/(2.0*PI),0.0,0.0);
	ALPHA = 1.0;
    if (angle > (progress-.5) * 2.0*PI){
		ALPHA = 0.0;
	}
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
