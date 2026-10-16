shader_type spatial;

uniform vec4 object_top_color : source_color = vec4(0.7, 0.2, 0.2, 1.0);
uniform vec4 object_bottom_color : source_color = vec4(0.2, 0.2, 0.7, 1.0);

uniform float object_color_split : hint_range(-10.0, 10.0) = 3;

uniform vec4 fog_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float fog_max_y = 0.0;
uniform float fog_min_y = -100.0;

varying float world_y; 
varying float local_y;

void vertex() {
    local_y = VERTEX.y + 0.5;

    vec4 world_position = MODEL_MATRIX * vec4(VERTEX, 1.0);
    world_y = world_position.y;
}

void fragment() {

    float color_factor = step(object_color_split, local_y);
    vec3 base_rgb = mix(object_bottom_color.rgb, object_top_color.rgb, color_factor);
    
    float fog_factor = smoothstep(fog_max_y, fog_min_y, world_y);
    
    ALBEDO = mix(base_rgb, fog_color.rgb, fog_factor);
}
