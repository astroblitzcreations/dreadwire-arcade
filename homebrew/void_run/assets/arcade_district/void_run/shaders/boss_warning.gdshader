shader_type canvas_item;
render_mode blend_add;

uniform float fade : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = UV;
	float edge = smoothstep(0.20, 0.0, abs(uv.y - 0.5));
	float scan = 0.55 + 0.45 * sin(uv.y * 780.0 - TIME * 35.0);
	float diagonal = step(0.55, fract((uv.x + uv.y * 0.42 - TIME * 0.32) * 18.0));
	float pulse = 0.62 + 0.38 * sin(TIME * 9.0);
	vec3 red = mix(vec3(0.30, 0.0, 0.02), vec3(1.0, 0.025, 0.08), diagonal * 0.38 + scan * 0.18);
	float alpha = fade * edge * (0.46 + pulse * 0.30);
	COLOR = vec4(red * (0.85 + pulse * 0.55), alpha);
}
