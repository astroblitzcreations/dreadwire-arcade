shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float scanline_strength : hint_range(0.0, 0.3) = 0.08;
uniform float vignette_strength : hint_range(0.0, 0.4) = 0.12;
uniform float chromatic_pixels : hint_range(0.0, 1.0) = 0.0;
void fragment() {
    vec2 uv = SCREEN_UV;
    vec2 shift = vec2(SCREEN_PIXEL_SIZE.x * chromatic_pixels, 0.0);
    vec3 color = vec3(texture(screen_texture, uv + shift).r,
        texture(screen_texture, uv).g, texture(screen_texture, uv - shift).b);
    float line = 1.0 - scanline_strength * (0.5 + 0.5 * sin(uv.y / SCREEN_PIXEL_SIZE.y * 3.14159265));
    vec2 centered = uv * 2.0 - 1.0;
    float vignette = 1.0 - vignette_strength * dot(centered, centered) * 0.5;
    COLOR = vec4(color * line * vignette, 1.0);
}
