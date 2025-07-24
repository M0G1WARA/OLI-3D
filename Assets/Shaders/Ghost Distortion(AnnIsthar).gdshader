// https://annie-isthar.itch.io/vaho-ghost-distortion-shader
// https://godotshaders.com/shader/vaho-ghost-distortion-shader/

shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, unshaded;

group_uniforms render;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D albedo_texture;

uniform float opacity : hint_range(0.0, 2.0) = 1.0;
uniform vec4 ghost_color : source_color = vec4(0, 1.0, 1.0, 1.0);

uniform float flicker_speed : hint_range(0.0, 5.0) = 1.2;
uniform float phase_frequency : hint_range(0.0, 1.0) = 0.4;

uniform float fresnel_strength : hint_range(0.0, 1.5) = 0.8;
uniform vec3 fresnel_color : source_color = vec3(1.0, 1.0, 1.0);

uniform float wave_amplitude: hint_range(0.0, 0.01) = 0.006;
uniform float wave_frequency: hint_range(0.0, 20.0) = 19.397;
uniform float wave_speed: hint_range(0.0, 10.0) = 3.618;
uniform float chroma_amount: hint_range(0.0, 10.0) = 1.0;

group_uniforms points;

uniform bool points_enabled = true;
uniform float point_field_scale: hint_range(1.0, 50.0) = 4.377;
uniform float point_size: hint_range(0.001, 0.008) = 0.008;
uniform float point_intensity: hint_range(0.0, 1.0) = 1.0;
uniform float point_axis_speed: hint_range(0.0, 0.5) = 0.051;
uniform int point_move_mode: hint_range(0, 3) = 1;
uniform vec3 point_color : source_color = vec3(1.0, 1.0, 1.0);

// Función de ruido
float random(vec2 st) {
    return fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec2 wave_offset = vec2(
        sin(SCREEN_UV.y * wave_frequency + TIME * wave_speed),
        sin(SCREEN_UV.x * wave_frequency + TIME * wave_speed)
    ) * wave_amplitude;

    vec2 distorted_uv = SCREEN_UV + wave_offset;

    vec2 red_uv   = distorted_uv + wave_offset * chroma_amount;
    vec2 blue_uv  = distorted_uv - wave_offset * chroma_amount;
    vec2 green_uv = distorted_uv;

    float r = texture(screen_texture, red_uv).r;
    float g = texture(screen_texture, green_uv).g;
    float b = texture(screen_texture, blue_uv).b;
    vec3 screen_color = vec3(r, g, b);

    float flicker = sin(TIME * flicker_speed) * 0.5 + 0.5;
    float phase = sin(TIME * phase_frequency * 6.2831) * 0.5 + 0.5;

    float fresnel_factor = pow(1.0 - dot(NORMAL, VIEW), 2.0) * fresnel_strength;
    vec3 fresnel = fresnel_color * fresnel_factor;

    vec4 base_texture = texture(albedo_texture, UV);
    vec3 base_color = base_texture.rgb * ghost_color.rgb;

    float point_accum = 0.0;
    if (points_enabled) {
        vec2 moving_uv = UV;
        vec2 offset = vec2(0.0);
        if (point_move_mode == 0) {
            offset = vec2(0.0, TIME * point_axis_speed);
        } else if (point_move_mode == 1) {
            offset = vec2(TIME * point_axis_speed, 0.0);
        } else if (point_move_mode == 2) {
            offset = vec2(TIME * point_axis_speed);
        } else if (point_move_mode == 3) {
            offset = vec2(
                sin(TIME * point_axis_speed * 1.3),
                cos(TIME * point_axis_speed * 1.7)
            );
        }

        moving_uv = fract(moving_uv + offset);
        vec2 grid_uv = moving_uv * point_field_scale;
        vec2 id = floor(grid_uv);
        vec2 f = fract(grid_uv) - 0.5;

        for (int j = -1; j <= 1; j++) {
            for (int i = -1; i <= 1; i++) {
                vec2 neighbor = vec2(float(i), float(j));
                vec2 cell_id = id + neighbor;
                vec2 point_pos = vec2(random(cell_id), random(cell_id * 1.3)) - 0.5;
                float d = length(f - point_pos);
                float point = 1.0 - smoothstep(point_size * 0.5, point_size, d);
                point_accum += point;
            }
        }

        point_accum = clamp(point_accum, 0.0, 1.0);
    }

    vec4 final_color = vec4(base_color, ghost_color.a);
    final_color.rgb = mix(final_color.rgb, screen_color, 0.6);
    final_color.rgb += fresnel;
    final_color.rgb = mix(final_color.rgb, point_color, point_intensity * point_accum);

    float final_alpha = ghost_color.a * opacity * flicker * phase;
    final_color.a = clamp(final_alpha, 0.3, 1.0);

    EMISSION = final_color.rgb;
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
}
