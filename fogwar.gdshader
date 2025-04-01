shader_type canvas_item;

uniform vec2 player_pos;
uniform float reveal_radius = 30.0;  // The area around the player that is revealed

void fragment() {
    vec2 uv_center = UV - player_pos;
    float dist = length(uv_center) * 500.0;  // Scale distance properly

    float alpha = smoothstep(reveal_radius, reveal_radius - 10.0, dist);

    COLOR = vec4(0.0, 0.0, 0.0, alpha);  // Adjust alpha based on distance
}