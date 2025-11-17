// Portal 2-like shader - adapted from https://godotshaders.com/shader/portal-2-like-shader/
shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo: hint_default_black, source_color;
uniform float size: hint_range(0.0,0.5) = 0.5;
uniform float size_inner: hint_range(0.1,1) = 0.2;

uniform sampler2D noise;

uniform vec4 portalFrameColor : source_color = vec4(0.0, 0.5, 1.0, 1.0);
uniform vec4 portalHighlightColor : source_color = vec4(0.5, 0.8, 1.0, 1.0);

// https://godotshaders.com/snippet/rotate/
vec2 rotateUV(vec2 uv, vec2 pivot, float angle)
{
    mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
                        vec2(cos(angle), sin(angle)));

    uv -= pivot;
    uv = uv * rotation;
    uv += pivot;
    return uv;
}

void fragment() {
    float dist = length(UV - vec2(0.5,0.5));

    vec2 nuv = UV;

    nuv = rotateUV(UV, vec2(0.5), 45.0*TIME*0.01);
    nuv.x += (TIME*0.1);
    nuv.y -= (TIME*0.1);

    vec4 ntexel = texture(noise,nuv);
    
    // Get the portal view from the viewport texture (this is your existing portal rendering)
    vec3 portal_view = texture(albedo, SCREEN_UV).rgb;

    float a = smoothstep(size, size-0.04, dist);
    float a2 = smoothstep(size, (ntexel.r*0.10)+(size-size_inner), dist);

    vec4 result = mix(portalHighlightColor, portalHighlightColor, a);
    ALPHA = a;

    if (a == 1.0) {
        result = vec4(portal_view, 1.0); // Use the viewport texture instead of solid color
    }

    if (a2 < 0.2) {
        result = portalHighlightColor;
    }

    result = mix(portalFrameColor, result, a2);

    ALBEDO = result.rgb;
    EMISSION = ALBEDO;
}