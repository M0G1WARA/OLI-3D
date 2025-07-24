// https://godotshaders.com/shader/selection-shader-colored/

shader_type spatial;
uniform float redmulti : hint_range(0.0, 1.0) = 0.0;
uniform float greenmulti : hint_range(0.0, 1.0) = 0.8;
uniform float bluemulti : hint_range(0.0, 1.0) = 0.4;

void fragment() {
	ALBEDO = vec3((1.0-(sin(TIME)*0.5))*redmulti,(1.0-(sin(TIME)*0.5))*greenmulti,(1.0-(sin(TIME)*0.5))*bluemulti);
	ALPHA = 0.4;
}
