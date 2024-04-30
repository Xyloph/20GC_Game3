shader_type canvas_item;

// range at which the frog will disappear under the waves (become invisible)
uniform float drowning : hint_range(0.0, 1.0);

void fragment() {
	if (drowning > 0.0) {
		// moving down on drowning
		vec2 moved_UV = vec2(UV.x, UV.y - drowning / 2.0);
		COLOR = texture(TEXTURE, moved_UV);
		
		// slowly fading away as well
		COLOR.a *= smoothstep(0.,drowning, 1.-UV.y);
	}
}
