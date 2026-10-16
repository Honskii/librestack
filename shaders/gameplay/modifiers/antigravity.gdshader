
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 flipped_uv = vec2(1.0 - SCREEN_UV.x, 1.0 - SCREEN_UV.y);
    
    vec4 screen_color = texture(SCREEN_TEXTURE, flipped_uv);
    COLOR = screen_color;
}