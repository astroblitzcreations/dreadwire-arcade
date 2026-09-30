shader_type canvas_item;

uniform float warp_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float black_hole_tier : hint_range(0.0, 8.0) = 0.0;
uniform float level_energy : hint_range(0.0, 1.0) = 0.0;
uniform vec2 black_hole_pos = vec2(0.74, 0.43);

float hash21(vec2 p) {
	p = fract(p * vec2(234.34, 435.345));
	p += dot(p, p + 34.23);
	return fract(p.x * p.y);
}

float noise21(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1.0, 0.0)), f.x),
		mix(hash21(i + vec2(0.0, 1.0)), hash21(i + vec2(1.0)), f.x), f.y);
}

vec3 star_layer(vec2 uv, float scale, float speed, float threshold, vec3 tint, float t) {
	vec2 grid = uv * scale;
	grid.x += t * speed;
	vec2 id = floor(grid);
	vec2 cell = fract(grid) - 0.5;
	float seed = hash21(id);
	vec2 offset = vec2(hash21(id + 7.3), hash21(id + 19.1)) - 0.5;
	float star = smoothstep(0.095, 0.0, length(cell - offset * 0.55)) * step(threshold, seed);
	float twinkle = 0.58 + 0.42 * sin(t * (2.5 + seed * 4.0) + seed * 18.0);
	return tint * star * twinkle;
}

vec3 black_hole(vec2 uv, float tier, float t) {
	vec2 p = uv - black_hole_pos;
	p.x *= 1.7777778;
	float d = max(length(p), 0.0005);
	float horizon = 0.034 + min(tier, 8.0) * 0.006;
	float angle = atan(p.y, p.x);
	float bend = angle + 0.15 / d + t * (0.20 + tier * 0.018);
	float disk_y = abs(p.y * (4.7 - min(tier, 6.0) * 0.22) + sin(bend * 9.0) * 0.008);
	float disk_mask = smoothstep(0.048, 0.002, disk_y) * smoothstep(horizon, horizon + 0.035, d) * smoothstep(0.42, 0.08, d);
	float photon = smoothstep(0.013, 0.0, abs(d - horizon * 1.42));
	float lens = smoothstep(horizon * 4.8, horizon * 1.2, d) * (0.45 + 0.55 * sin(bend * 13.0));
	vec3 hot = mix(vec3(1.0, 0.18, 0.04), vec3(0.22, 0.64, 1.0), 0.5 + 0.5 * sin(bend * 3.0 + tier));
	vec3 result = hot * disk_mask * (1.4 + tier * 0.16);
	result += vec3(0.75, 0.88, 1.0) * photon * 2.8;
	result += vec3(0.24, 0.10, 0.55) * lens * 0.22;
	result *= smoothstep(horizon * 0.92, horizon * 1.08, d);
	return result;
}

void fragment() {
	vec2 uv = UV;
	float t = TIME;
	vec2 drift = vec2(uv.x + t * (0.012 + level_energy * 0.014), uv.y);
	float n1 = noise21(drift * vec2(3.2, 2.2) + vec2(t * 0.025, 0.0));
	float n2 = noise21(drift * vec2(7.5, 5.5) - vec2(t * 0.018, t * 0.009));
	float cloud = smoothstep(0.25, 0.9, n1 * 0.68 + n2 * 0.42);
	vec3 color = mix(vec3(0.002, 0.005, 0.018), vec3(0.10, 0.012, 0.17), cloud * (0.48 + level_energy * 0.22));
	color += star_layer(uv, 34.0, 0.12, 0.955, vec3(0.42, 0.65, 1.0), t) * 0.55;
	color += star_layer(uv, 20.0, 0.28, 0.94, vec3(0.86, 0.93, 1.0), t) * 0.78;
	color += star_layer(uv, 10.0, 0.62, 0.91, vec3(1.0, 0.72, 0.92), t);

	if (black_hole_tier > 0.01) {
		color += black_hole(uv, black_hole_tier, t);
	}

	if (warp_intensity > 0.001) {
		vec2 p = uv - vec2(0.72, 0.5);
		p.x *= 1.7777778;
		float r = max(length(p), 0.018);
		float a = atan(p.y, p.x);
		float lanes = pow(max(0.0, sin(a * 42.0 + sin(a * 7.0 + t) * 1.8)), 13.0);
		float rings = pow(max(0.0, sin(38.0 / r - t * 19.0)), 9.0);
		float tunnel = (lanes * (0.20 / r) + rings * 0.75) * warp_intensity;
		vec3 warp_color = mix(vec3(0.12, 0.52, 1.0), vec3(0.92, 0.18, 1.0), 0.5 + 0.5 * sin(a * 5.0 + t));
		color = mix(color, color * 0.24 + warp_color * tunnel, warp_intensity);
		color += vec3(0.78, 0.93, 1.0) * smoothstep(0.10, 0.0, r) * warp_intensity;
	}

	COLOR = vec4(color, 1.0);
}
