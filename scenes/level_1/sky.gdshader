shader_type sky;

uniform vec3 sky_top_color : source_color = vec3(0.2, 0.4, 1.0);
uniform vec3 sky_horizon_color : source_color = vec3(0.4, 0.6, 1.0);
uniform float horizon_blur : hint_range(0.0, 1.0, 0.1) = 0.05;

// Cloud parameters
uniform sampler2D noise_texture;
uniform vec3 cloud_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float cloud_scale = 2.0;
uniform float cloud_density = 0.5;
uniform float cloud_speed = 0.1;
uniform float time;

void sky() {
    // Get the screen position
    float horizon = abs(EYEDIR.y);

    // Create gradient for sky
    vec3 sky = mix(sky_horizon_color, sky_top_color, pow(horizon, horizon_blur));

    // Cloud generation
    vec2 cloud_uv = EYEDIR.xz / (EYEDIR.y + 1.0);
    cloud_uv *= cloud_scale;
    cloud_uv += TIME * cloud_speed;

    float noise = texture(noise_texture, cloud_uv).r;
    float cloud_mask = smoothstep(cloud_density, cloud_density + 0.1, noise);

    // Mix sky with clouds
    vec3 final_color = mix(sky, cloud_color, cloud_mask * (1.0 - horizon));

    COLOR = final_color;
}