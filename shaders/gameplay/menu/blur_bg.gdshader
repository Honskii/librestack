shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float blur_amount : hint_range(0.0, 5.0) = 3.0;

uniform vec4 tint_color : source_color = vec4(0.0, 0.0, 0.0, 0.3);

void fragment() {
    vec4 screen_col = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
    
    vec3 final_rgb = mix(screen_col.rgb, tint_color.rgb, tint_color.a);
    
    COLOR = vec4(final_rgb, 1.0);
}