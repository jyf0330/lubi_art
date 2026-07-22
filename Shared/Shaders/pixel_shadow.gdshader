shader_type canvas_item;

uniform float max_opacity : hint_range(0.0, 1.0, 0.01) = 0.58;
uniform float fade_start : hint_range(0.0, 1.0, 0.01) = 0.72;
uniform float fade_end : hint_range(0.0, 1.0, 0.01) = 0.96;
uniform float fade_bands : hint_range(2.0, 8.0, 1.0) = 5.0;

void fragment() {
	vec4 source = texture(TEXTURE, UV);
	float luminance = dot(source.rgb, vec3(0.299, 0.587, 0.114));
	float darkness = 1.0 - luminance;
	float fade = clamp((darkness - fade_start) / (fade_end - fade_start), 0.0, 1.0);
	float stepped_fade = floor(fade * fade_bands + 0.5) / fade_bands;
	COLOR = vec4(0.0, 0.0, 0.0, source.a * stepped_fade * max_opacity);
}
