shader_type canvas_item;

uniform vec4 top_color : source_color = vec4(0.1, 0.3, 0.8, 1.0);
uniform vec4 bottom_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform float blend_position : hint_range(0.0, 1.0) = 0.75;

uniform float blend_smoothness : hint_range(0.01, 0.5) = 0.5;

void fragment() {
    float screen_y = 1.0 - UV.y;

    float low_bound = blend_position - blend_smoothness;
    float high_bound = blend_position + blend_smoothness;

    float factor = smoothstep(low_bound, high_bound, screen_y);

    vec3 final_color = mix(bottom_color.rgb, top_color.rgb, factor);

    COLOR = vec4(final_color, 1.0);
}
