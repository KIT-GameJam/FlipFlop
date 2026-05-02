shader_type canvas_item;

uniform float time_scale : hint_range(0.0, 5.0) = 1.0;
uniform float spiral_strength : hint_range(0.0, 15.0) = 7.0;
// Pull-Geschwindigkeit ist jetzt unabhängig von der Density
uniform float pull_speed : hint_range(0.0, 5.0) = 1.0;
// Optional: zusätzliche langsame Rotation des ganzen Wirbels
uniform float rotation_speed : hint_range(-2.0, 2.0) = -2.0;
uniform float particle_density : hint_range(5.0, 200.0) = 70.0;
uniform float contrast : hint_range(0.001, 0.3) = 0.04;
uniform float portal_radius : hint_range(0.1, 0.5) = 0.48;
uniform float core_size : hint_range(0.0, 0.2) = 0.2;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float pnoise(vec2 p, float period_x) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float ix0 = mod(i.x,         period_x);
    float ix1 = mod(i.x + 1.0,   period_x);

    float a = hash(vec2(ix0, i.y));
    float b = hash(vec2(ix1, i.y));
    float c = hash(vec2(ix0, i.y + 1.0));
    float d = hash(vec2(ix1, i.y + 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void fragment() {
    vec2 uv   = UV - vec2(0.5);
    float dist  = length(uv);
    float angle = atan(uv.y, uv.x);

    float t = TIME * time_scale;
    float arms = floor(particle_density);

    // Spirale + langsame Gesamtrotation
    float spiral  = angle + spiral_strength * log(dist + 0.05) + t * rotation_speed;
    float angular = spiral * arms / 6.28318530718;

    // Radialer Sog -- jetzt in "Zellen pro Sekunde", nicht mehr an Density gekoppelt
	float radial = dist * particle_density + t * pull_speed * 8.0;
    
	float n  = pnoise(vec2(angular, radial), arms);
    float bw = smoothstep(0.5 - contrast, 0.5 + contrast, n);

    float edge = smoothstep(portal_radius, portal_radius * 0.85, dist);
    float core = smoothstep(0.0, core_size, dist);
    float alpha = edge * core;

    COLOR = vec4(vec3(bw), alpha);
}