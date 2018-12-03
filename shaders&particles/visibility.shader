shader_type canvas_item;
//render_mode blend_sub;
uniform vec4 transparency: hint_color;

void fragment(){
	COLOR = texture(TEXTURE,UV);
	if(AT_LIGHT_PASS){
		COLOR*=transparency;
	}/*else{
		COLOR = texture(TEXTURE,UV);
	}*/
	
}

void light(){
	//LIGHT = vec4(0.0,0.0,0.0,0.0);
}