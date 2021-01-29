shader_type canvas_item;

//uniform vec4 from_color : hint_color;
uniform vec4 to_color : hint_color;

void fragment() {
    vec4 curr_color = texture(TEXTURE, UV);

    //if (curr_color == from_color){
	if (curr_color.x > 0.9 && curr_color.y > 0.9 
	    && curr_color.z > 0.9){
        COLOR = to_color;
    }else{
        COLOR = curr_color;
    }
}