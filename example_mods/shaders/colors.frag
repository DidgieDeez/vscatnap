#pragma header
uniform float iTime;
uniform vec2 iResolution;

// pseudo rand
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

// soft circle
float softCircle(vec2 uv, vec2 center, float radius) {
    float dist = distance(uv, center);
    return smoothstep(radius, radius - 0.05, dist);
}

// Simplex 2D noise
vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187, 0.366025403784439,
             -0.577350269189626, 0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod(i, 289.0);
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0))
    + i.x + vec3(0.0, i1.x, 1.0));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
      dot(x12.zw,x12.zw)), 0.0);
    m = m*m;
    m = m*m;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h*h);
    vec3 g;
    g.x = a0.x * x0.x + h.x * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// Fractal Brownian Motion
float fbm(vec2 x) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100);
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
    for (int i = 0; i < 5; ++i) {
        v += a * snoise(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main()
{
    vec2 uv = openfl_TextureCoordv;
    float time = iTime;

    //  jittery UVs 
    uv += 0.1 * vec2(sin(time * 10.0 + uv.y * 20.0), cos(time * 10.0 + uv.x * 20.0));

    vec2 center = vec2(0.5);
    
    float dist = distance(uv, center);
    float angle = atan(uv.y - center.y, uv.x - center.x);
    
    // spiral effect
    float spiral = sin(dist * 40.0 - angle * 2.0 + sin(time) * 2.0) * 0.5 + (0.2 + cos(time) * 0.5);
    vec3 spiralColor = vec3(spiral * (1.0 - dist));
    
    // nebula effect
    vec2 q = vec2(
        fbm(uv + 0.1 * iTime * 0.3),
        fbm(uv + vec2(1.0))
    );
    
    vec2 r = vec2(
        fbm(uv + 1.0 * q + vec2(1.7, 9.2) + 0.15 * iTime * 0.3),
        fbm(uv + 1.0 * q + vec2(8.3, 2.8) + 0.126 * iTime * 0.3)
    );
    
    float f = fbm(uv + r);
    
    vec3 nebulaColor = mix(vec3(0.2, 0.0, 0.3), vec3(0.6, 0.3, 0.7), f);
    nebulaColor += 0.05 * sin(f * 10.0 + iTime * 0.3) + 0.1 * smoothstep(0.4, 0.6, f);
    
    vec3 finalColor = mix(spiralColor, nebulaColor, 0.5);
    
    finalColor *= vec3(
        sin(time * 33.0 + uv.x * 55.0), 
        cos(time * 22.0 + uv.y * 55.0), 
        sin(time * 1.5 + 3.14 + uv.x * 55.0 + uv.y * 55.0)
    );

    finalColor = mix(finalColor, vec3(rand(uv + time), rand(uv - time), rand(uv + time * 2.0)), 0.5);

    uv += vec2(sin(time * 5.0 + uv.y * 10.0), cos(time * 5.0 + uv.x * 10.0)) * 0.1;
    finalColor *= vec3(sin(time * 5.0 + uv.x * 10.0), cos(time * 5.0 + uv.y * 10.0), sin(time * 5.0 + uv.x * 10.0 + uv.y * 10.0));
    
    gl_FragColor = vec4(clamp(finalColor, 0.0, 1.0), 1.0);
}